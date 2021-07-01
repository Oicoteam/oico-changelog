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
          puts 'Fetch tags'

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

          public_send(release_type)
        end

        private

        def current_version_segments
          current_version = last_release
          current_version = DEFAULT_VERSION if current_version.nil? || current_version.empty?

          puts "Current version: #{current_version}"

          current_version.gsub(/v/, '').split('.').map(&:to_i)
        end

        def push_next_tag(next_tag)
          version = "v#{next_tag}"

          puts "Add git tag #{version}"

          Changelog.new.add_release!(version)

          if system("git tag \"#{version}\" && git push --tags")
            puts 'Release done successfully!'
          else
            puts 'Unknown error!'
          end
        end
      end
    end
  end
end
