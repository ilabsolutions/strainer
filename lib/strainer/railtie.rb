# frozen-string-literal: true

require 'fileutils'
require 'rails'

module Strainer
  # Implements a railtie that enables this plugin to be used in rails apps
  class Railtie < ::Rails::Railtie
    LOG_PATH = 'log/incompatible_code.log'
    def self.setup!
      log_file_path = ::Rails.root.join(LOG_PATH)
      FileUtils.touch(log_file_path)
    end

    config.to_prepare do
      Strainer::Railtie.setup!
    end

    initializer 'strainer.initialize' do
      Strainer::Railtie.configure do
        log_file_path = ::Rails.root.join(LOG_PATH)
        config.logger = FileLogger.new(log_file_path)
      end
      %i[action_controller active_record].each do |component|
        ActiveSupport.on_load(component, run_once: true) do
          Strainer::Patches.setup!(component)
        end
      end
    end
  end
end
