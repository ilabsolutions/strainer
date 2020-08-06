# frozen_string_literal: true

module MissingConfigurationMethods
  def ancestors; end

  def logger
    Strainer::FileLogger.new 'spec/fixtures/files/test.log'
  end
end

RSpec.configure do |config|
  config.before :suite do
    Rails::Railtie::Configuration.include MissingConfigurationMethods
  end
  config.before(:all, behavior: true) do
    described_class.init!
  end
end
