module Oico::Changelog::Release
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
end
