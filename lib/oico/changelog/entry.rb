module Oico
  class Changelog
    class Entry
      def initialize(type:, body: last_commit, ref_type: nil, ref_id: nil, user: github_user)
        id, message = extract_id_and_message(body.lines)

        @type     = type
        @message  = message
        @ref_type = ref_type || (id ? :pull : :issues)
        @ref_id   = ref_id || id || 'NOT_FOUND'
        @user     = user
      end

      def write
        Dir.mkdir(Changelog::ENTRIES_PATH) unless Dir.exist?(Changelog::ENTRIES_PATH)

        File.write(path, content)

        path
      end

      def content
        period = '.' unless message.end_with?('.')

        "* #{ref}: #{message}#{period} ([@#{user}][])\n"
      end

      private

      attr_accessor :message
      attr_reader   :type, :ref_type, :ref_id, :user, :commit_title, :commit_message

      def extract_id_and_message(body)
        extract_commit_message(body)

        id, message = /(?:.*)?#(\d+).?(.*)/.match(commit_title)&.captures || [nil, commit_title]
        message     = commit_message unless commit_message.empty?

        [id, message]
      end

      def path
        format(Changelog::ENTRIES_PATH_TEMPLATE, type: type, name: str_to_filename(commit_title))
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

      def last_commit
        `git log -1 --pretty=%B`
      end

      def extract_commit_message(body)
        @commit_title   = body.first.chomp
        @commit_message = body.last.chomp
      end
    end
  end
end
