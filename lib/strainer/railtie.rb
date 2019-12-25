# frozen-string-literal: true

require 'fileutils'

module Strainer
  # Implements a railtie that enables this plugin to be used in rails apps
  class Railtie < ::Rails::Railtie
    def self.setup!
      log_file_path = ::Rails.root.join('log/incompatible_code.log')
      FileUtils.touch(log_file_path)
      config.logger = FileLogger.new(log_file_path)
    end

    config.to_prepare do
      Strainer::Railtie.setup!
    end

    initializer 'strainer.initialize' do
      %i[action_controller active_record].each do |component|
        ActiveSupport.on_load(component) do
          Strainer::Patches.setup!(component)
        end
      end
    end
  end
end
