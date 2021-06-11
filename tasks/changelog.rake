# frozen_string_literal: true

require_relative '../lib/oico/changelog'

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

    cmd = "git commit -a -m 'Update Changelog'"

    puts cmd
    system cmd
  end

  desc 'Delete entries'
  task :delete do
    raise 'No entries!' unless Oico::Changelog.pending?

    Oico::Changelog.delete_entries!
    cmd = "git commit -a -m 'Update Changelog'"
    puts cmd
    system cmd
  end

  desc 'Create release tag'
  task :release, [:type] do |_task, args|
    Oico::Changelog::Release.public_send(args[:type])
  end

  desc 'Create release tag automatically'
  task :release_auto do
    Oico::Changelog::Release.auto_detect

    cmd = "git push origin main"

    puts cmd
    system cmd
  end

  desc 'Check pending entries'
  task :check_clean do
    next unless Oico::Changelog.pending?

    puts '*** Pending changelog entries!'
    puts 'Do `bundle exec rake changelog:merge`'
    exit(1)
  end
end
