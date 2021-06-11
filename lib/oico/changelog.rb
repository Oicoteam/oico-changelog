require 'dotenv/load'
require 'strscan'
require 'oico/changelog/version'
require 'oico/changelog/constants'
require 'oico/changelog/entry'
require 'oico/changelog/release'

module Oico
  class Changelog
    include Oico::Changelog::Constants

    class Error < StandardError; end

    attr_reader :unreleased

    def initialize(content: File.read(Changelog::PATH), entries: Changelog.read_entries)
      string        = StringScanner.new(content)

      @header       = string.scan_until(Changelog::FIRST_HEADER)
      @unreleased   = parse_release(string.scan_until(/\n(?=## )/m))
      @rest         = string.rest.chomp
      @entries      = entries
      @file_content = [header, unreleased_content]
    end

    def merge!
      yield if block_given?

      file_content << rest unless rest.empty?
      file_content << EOF  unless file_content[-1]&.end_with?("\n")

      content = file_content.join("\n").gsub(/[\n]{2,}/, "\n\n")

      write_file(content)
    end

    def add_release!
      merge! do
        release_title = "\n## #{Changelog::Release.last_release} (#{current_date})\n"

        file_content.insert(1, release_title)
      end
    end

    private

    attr_reader :header, :rest, :entries, :file_content

    def write_file(content)
      File.write(Changelog::PATH, content)

      self
    end

    def parse_release(unreleased_entries)
      return {} unless unreleased_entries

      unreleased_entries.lines
                        .map(&:chomp)
                        .reject(&:empty?)
                        .slice_before(Changelog::HEADER)
                        .to_h { |header, *entries| [Changelog::HEADER.match(header)[1], entries] }
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
      all      = unreleased.merge(entry_map) { |_k, v1, v2| v1.concat(v2) }
      distinct = Changelog::TYPE_TO_HEADER.values.to_h { |v| [v, nil] }

      distinct.merge(all).compact
    end

    def current_date
      Time.now.strftime("%d-%m-%Y")
    end

    class << self
      def pending?
        entry_paths.any?
      end

      def read_entries
        entry_paths.to_h { |path| [path, File.read(path)] }
      end

      def delete_entries!
        entries = Changelog.read_entries

        entries.each_key { |path| File.delete(path) }
      end

      def entry_paths
        Dir["#{Changelog::ENTRIES_PATH}*"]
      end
    end
  end
end
