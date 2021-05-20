require 'byebug'
require 'strscan'
require_relative 'changelog/version'
require_relative 'changelog/constants'
require_relative 'changelog/entry'

module Oico
  class Changelog
    include Oico::Changelog::Constants

    class Error < StandardError; end

    attr_reader :header, :rest

    def initialize(content: File.read(Changelog::PATH), entries: Changelog.read_entries)
      ss          = StringScanner.new(content)

      @header     = ss.scan_until(Changelog::FIRST_HEADER)
      @unreleased = parse_release(ss.scan_until(/\n(?=## )/m))
      @rest       = ss.rest
      @entries    = entries
    end

    def merge!
      File.write(Changelog::PATH, merge_content)

      self
    end

    def merge_content
      merged_content = [@header, unreleased_content, @rest.chomp, *new_contributor_lines].join("\n")

      merged_content << EOF
    end

    def delete_entries!
      entries.each_key { |path| File.delete(path) }
    end

    private

    attr_reader :entries

    def parse_release(unreleased_entries)
      unreleased_entries.lines
                        .map(&:chomp)
                        .reject(&:empty?)
                        .slice_before(Changelog::HEADER)
                        .to_h { |header, *entries| [Changelog::HEADER.match(header)[1], entries] }
    end

    def new_contributor_lines
      contributors.map { |user| format(Changelog::CONTRIBUTOR, user: user) }
                  .reject { |line| @rest.include?(line) }
    end

    def contributors
      contributors = entries.values.flat_map do |entry|
        entry.match(/\. \((?<contributors>.+)\)\n/)[:contributors].split(',')
      end

      contributors.join.scan(Changelog::SIGNATURE).flatten
    end

    def unreleased_content
      entry_map  = parse_entries(entries)
      merged_map = merge_entries(entry_map)

      merged_map.flat_map { |header, things| ["### #{header}\n", *things, ''] }.join("\n")
    end

    def parse_entries(path_content_map)
      changes = Hash.new { |h, k| h[k] = [] }

      path_content_map.each do |path, content|
        header = Changelog::TYPE_TO_HEADER.fetch(Changelog::TYPE_REGEXP.match(path)[1].to_sym)

        changes[header].concat(content.lines.map(&:chomp))
      end

      changes
    end

    def merge_entries(entry_map)
      all       = @unreleased.merge(entry_map) { |_k, v1, v2| v1.concat(v2) }
      canonical = Changelog::TYPE_TO_HEADER.values.to_h { |v| [v, nil] }

      canonical.merge(all).compact
    end

    class << self
      def pending?
        entry_paths.any?
      end

      def read_entries
        entry_paths.to_h { |path| [path, File.read(path)] }
      end

      def entry_paths
        Dir["#{Changelog::ENTRIES_PATH}*"]
      end
    end
  end
end
