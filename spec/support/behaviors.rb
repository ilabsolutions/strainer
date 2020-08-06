# frozen_string_literal: true

require 'fileutils'

module MissingConfigurationMethods
  LOG_PATH = 'tmp/test.log'

  def ancestors; end

  def logger
    Strainer::FileLogger.new LOG_PATH
  end
end

RSpec.configure do |config|
  config.before :suite do
    FileUtils.touch(MissingConfigurationMethods::LOG_PATH)
    Rails::Railtie::Configuration.include MissingConfigurationMethods
  end
  config.before(:all, behavior: true) do
    described_class.init!
  end
end
