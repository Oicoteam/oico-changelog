# frozen_string_literal: true

module Oico::Changelog::Constants
  CONTRIBUTOR = '[@%<user>s]: https://github.com/%<user>s'
  ENTRIES_PATH = 'changelog/'
  ENTRIES_PATH_TEMPLATE = "#{ENTRIES_PATH}%<type>s_%<name>s.md"
  EOF = "\n"
  FIRST_HEADER = /#{Regexp.escape("## production (unreleased)\n")}/m.freeze
  HEADER = /### (.*)/.freeze
  MAX_LENGTH = 40
  MESSAGE_REGEX = /(?:.*)#(\d+)[^\/]+\/(.*?)\/.+/.freeze
  PATH = 'CHANGELOG.md'
  REF_URL = ENV["REF_URL"]
  SIGNATURE = Regexp.new(format(Regexp.escape('[@%<user>s][]'), user: '([\w-]+)'))
  TYPE_REGEXP = /#{Regexp.escape(ENTRIES_PATH)}([a-z]+)_/.freeze
  TYPE_TO_HEADER = { change: 'Changes', feature: 'New features', fix: 'Bug fixes', dependabot: 'Dependencies' }.freeze
end
