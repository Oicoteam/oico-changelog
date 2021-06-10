module Oico
  class Changelog
    class Release
      FEATURE_REGEX = /changelog\/feature/.freeze
      CHANGE_REGEX  = /changelog\/change/.freeze

      class << self
        def major
          `./bin/update_tags -M`
        end

        def minor
          `./bin/update_tags -m`
        end

        def patch
          `./bin/update_tags -p`
        end

        def last_release
          `git fetch --all --tags`
          `git tag`.chomp
        end

        def auto_detect
          changelog  = Changelog.new
          unreleased = changelog.unreleased

          return if unreleased.empty?

          release_type = :patch

          if unreleased[Changelog::TYPE_TO_HEADER[:change]]&.any?
            release_type = :major
          elsif unreleased[Changelog::TYPE_TO_HEADER[:feature]]&.any?
            release_type = :minor
          end

          # changelog.add_release!

          # public_send(release_type)
          release_type
        end
      end
    end
  end
end
