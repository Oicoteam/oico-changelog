module Oico
  class Changelog
    class Entry
      def initialize(type:, body: last_commit_title, ref_type: nil, ref_id: nil, user: github_user)
        id, body = extract_id(body)

        @type     = type
        @body     = body
        @ref_type = id ? :issues : :pull
        @ref_id   = id || 'x'
        @user     = user
      end

      def write
        Dir.mkdir(Changelog::ENTRIES_PATH) unless Dir.exist?(Changelog::ENTRIES_PATH)

        File.write(path, content)

        path
      end

      def content
        period = '.' unless body.end_with? '.'

        "* #{ref}: #{body}#{period} ([@#{user}][])\n"
      end

      private

      attr_accessor :body
      attr_reader   :type, :ref_type, :ref_id, :user

      def extract_id(body)
        /^\[Fix(?:es)? #(\d+)\] (.*)/.match(body)&.captures || [nil, body]
      end

      def path
        format(Changelog::ENTRIES_PATH_TEMPLATE, type: type, name: str_to_filename(body))
      end

      def str_to_filename(str)
        str.downcase
           .split
           .each { |s| s.gsub!(/\W/, '') }
           .reject(&:empty?)
           .inject do |result, word|
             s = "#{result}_#{word}"

             return result if s.length > Changelog::MAX_LENGTH

             s
           end
      end

      def github_user
        user = `git config --global credential.username`.chomp

        if user.empty?
          warn 'Set your username with `git config --global credential.username "myusernamehere"`'
        end

        user
      end

      def ref
        "[##{ref_id}](#{Changelog::REF_URL}/#{ref_type}/#{ref_id})"
      end

      def last_commit_title
        `git log -1 --pretty=%B`.lines.first.chomp
      end
    end
  end
end
