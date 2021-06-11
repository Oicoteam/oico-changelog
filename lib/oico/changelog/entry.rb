module Oico
  class Changelog
    class Entry
      def initialize(body: last_commit, user: last_commit_user, type: nil, ref_type: nil, ref_id: nil)
        extracted_message, extracted_id, extracted_type = extract_id_and_message(body.lines)

        @type     = type || extracted_type
        @message  = extracted_message
        @ref_type = ref_type || (extracted_id ? :pull : :issues)
        @ref_id   = ref_id || extracted_id || 'NOT_FOUND'
        @user     = user
      end

      def write
        Dir.mkdir(Changelog::ENTRIES_PATH) unless Dir.exist?(Changelog::ENTRIES_PATH)
        File.write(path, content)

        path
      end

      def content
        period = '.' unless message.end_with?('.')

        "* #{ref}: #{message}#{period} #{user.include?(" ") ? "([#{user}])" : "([@#{user}])"}\n"
      end

      private

      attr_accessor :message
      attr_reader   :type, :ref_type, :ref_id, :user, :commit_title, :commit_message

      def extract_id_and_message(body)
        extract_commit_message(body)

        matches  = Changelog::MESSAGE_REGEX.match(commit_title)&.captures
        id, type = matches || [nil, 'feature']
        message  = commit_message.empty? ? commit_title : commit_message

        [message, id, type]
      end

      def path
        format(Changelog::ENTRIES_PATH_TEMPLATE, type: type, name: str_to_filename(commit_title))
      end

      def str_to_filename(string)
        string.downcase
              .split
              .each { |s| s.gsub!(/\W/, '') }
              .reject(&:empty?)
              .inject do |result, word|
                concatenated_string = "#{result}_#{word}"

                 return result if concatenated_string.length > Changelog::MAX_LENGTH

                 concatenated_string
              end
      end

      def ref
        "[##{ref_id}](#{Changelog::REF_URL}/#{ref_type}/#{ref_id})"
      end

      def last_commit_user
        `git log -1 --pretty=format:'%an'`
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
