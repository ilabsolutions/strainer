# frozen_string_literal: true

require 'ougai'

module Strainer
  class FileLogger < ::Ougai::Logger
    include ActiveSupport::LoggerThreadSafeLevel
    include LoggerSilence # required

    def initialize(*args)
      super
      after_initialize if respond_to? :after_initialize
    end

    # default JSON format is OK
    def create_formatter
      ::Ougai::Formatters::Bunyan.new
    end
  end
end
