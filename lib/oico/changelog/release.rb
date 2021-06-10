module Oico::Changelog::Release
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
      entry_keys   = Oico::Changelog.read_entries.keys
      release_type = :patch

      entry_keys.each do |key|
        release_type = :minor if key.match?(FEATURE_REGEX)

        if key.match?(CHANGE_REGEX)
          release_type = :major

          break
        end
      end

      public_send(release_type)
    end
  end
end
