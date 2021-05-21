# frozen_string_literal: true

module Oico::Changelog::Constants
  ENTRIES_PATH = 'changelog/'
  FIRST_HEADER = /#{Regexp.escape("## production (unreleased)\n")}/m.freeze
  ENTRIES_PATH_TEMPLATE = "#{ENTRIES_PATH}%<type>s_%<name>s.md"
  TYPE_REGEXP = /#{Regexp.escape(ENTRIES_PATH)}([a-z]+)_/.freeze
  TYPE_TO_HEADER = { new: 'New features', fix: 'Bug fixes', change: 'Changes' }.freeze
  HEADER = /### (.*)/.freeze
  PATH = 'CHANGELOG.md'
  REF_URL = ENV["REF_URL"]
  MAX_LENGTH = 40
  CONTRIBUTOR = '[@%<user>s]: https://github.com/%<user>s'
  SIGNATURE = Regexp.new(format(Regexp.escape('[@%<user>s][]'), user: '([\w-]+)'))
  EOF = "\n"
end
