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
    FileUtils.mkdir_p('tmp')
    FileUtils.touch(MissingConfigurationMethods::LOG_PATH)
    Rails::Railtie::Configuration.include MissingConfigurationMethods
  end
  config.before(:all, behavior: true) do
    described_class.init!
  end
  config.before(:all, active_record: true) do
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

    ActiveRecord::Schema.define(version: 1) do
      create_table :fakes do |t|
        t.string :email, default: 'test@test.test'
      end
    end
  end
  config.after(:all, active_record: true) do
    ActiveRecord::Base.connection.close
  end
end
