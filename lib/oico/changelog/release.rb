module Oico
  class Changelog
    class Release
      FEATURE_REGEX   = /changelog\/feature/.freeze
      CHANGE_REGEX    = /changelog\/change/.freeze
      DEFAULT_VERSION = 'v1.0.0'

      class << self
        def major
          version = current_version_segments

          version[0] += 1
          version[1]  = 0
          version[2]  = 0

          push_next_tag(version.join('.'))
        end

        def minor
          version = current_version_segments

          version[1] += 1
          version[2]  = 0

          push_next_tag(version.join('.'))
        end

        def patch
          version = current_version_segments

          version[2] += 1

          push_next_tag(version.join('.'))
        end

        def last_release
          p 'Fetch tags'

          `git fetch --all --tags`
          `git describe --tags \`git rev-list --tags --max-count=1\``.chomp.strip
        end

        def auto_detect
          changelog  = Changelog.new
          header     = Changelog::TYPE_TO_HEADER
          unreleased = changelog.unreleased

          return if unreleased.empty?

          release_type = :patch
          release_type = :minor if unreleased[header[:feature]]&.any?
          release_type = :major if unreleased[header[:change]]&.any?

          changelog.add_release!

          public_send(release_type)
        end

        private

        def current_version_segments
          current_version = last_release
          current_version = DEFAULT_VERSION if current_version.nil? || current_version.empty?

          p "Current version: #{current_version}"

          current_version.gsub(/v|\./, '').chars.map(&:to_i)
        end

        def push_next_tag(next_tag)
          p "Add git tag v#{next_tag}"

          if system("git tag \"v#{next_tag}\"") && system('git push --tags')
            p 'Release done successfully!'
          else
            p 'Unknown error!'
          end
        end
      end
    end
  end
end
