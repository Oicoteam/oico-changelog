module Oico
  class Changelog
    class Release
      FEATURE_REGEX = /changelog\/feature/.freeze
      CHANGE_REGEX  = /changelog\/change/.freeze

      class << self
        def major
          system("sh #{Changelog.bin}/update_tags.sh -M")
        end

        def minor
          system("sh #{Changelog.bin}/update_tags.sh -m")
        end

        def patch
          system("sh #{Changelog.bin}/update_tags.sh -p")
        end

        def last_release
          `git fetch --all --tags`
          `git describe --abbrev=0 --tags`.chomp
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
      end
    end
  end
end
