require 'oico/changelog'
require 'rails'

module Oico
  class Changelog
    class Railtie < Rails::Railtie
      railtie_name :oico_changelog

      rake_tasks do
        load 'oico/tasks/changelog.rake'
      end
    end
  end
end
