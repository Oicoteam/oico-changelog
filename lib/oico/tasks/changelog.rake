# frozen_string_literal: true

require 'oico/changelog'

namespace :changelog do
  %i[feature fix change].each do |type|
    desc "Create a Changelog entry (#{type})"
    task type, [:id] do |_task, args|
      ref_type = :pull if args[:id]
      path     = Oico::Changelog::Entry.new(type: type, ref_id: args[:id], ref_type: ref_type).write

      puts "Entry '#{path}' created with success!"
    end
  end

  desc 'Create a Changelog entry automatically'
  task :entry_auto, [:id] do |_task, args|
    ref_type = :pull if args[:id]
    path     = Oico::Changelog::Entry.new(ref_id: args[:id], ref_type: ref_type).write

    puts "Entry '#{path}' created with success!"
  end

  desc 'Merge entries'
  task :merge do
    raise 'No entries!' unless Oico::Changelog.pending?

    Oico::Changelog.new.merge!

    puts 'Entries merged to CHANGELOG.md with success!'
  end

  desc 'Delete entries'
  task :delete do
    raise 'No entries!' unless Oico::Changelog.pending?

    Oico::Changelog.delete_entries!

    puts 'Entries deleted with success!'
  end

  desc 'Create release tag'
  task :release, [:type] do |_task, args|
    Oico::Changelog::Release.public_send(args[:type])

    puts 'Tag released with success!'
  end

  desc 'Create release tag automatically'
  task :release_auto do
    Oico::Changelog::Release.auto_detect

    puts 'Tag released automatically with success!'
  end

  desc 'Check pending entries'
  task :check_clean do
    unless Oico::Changelog.pending?
      puts 'No pending changelog entries!'
      next
    end

    puts '*** Pending changelog entries!'
    puts 'Do `bundle exec rake changelog:merge`'
    exit(1)
  end
end
