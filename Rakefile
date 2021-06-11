require 'bundler'
require 'bundler/gem_tasks'
require 'rake'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

Dir['tasks/**/*.rake'].each { |t| load t }
