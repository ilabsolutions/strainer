# frozen_string_literal: true

require 'ougai'
require 'active_support'

module Strainer
  # Implements a JSON style structured log
  class FileLogger < ::Ougai::Logger
    include ActiveSupport::LoggerThreadSafeLevel
    include ActiveSupport::LoggerSilence # required

    RUBY_STACK_REGEX = %r{\A
        (?<file>.+)       # Matches './spec/notice_spec.rb'
        :
        (?<line>\d+)      # Matches '43'
        :in\s
        `(?<function>.*)' # Matches "`block (3 levels) in <top (required)>'"
      \z}x.freeze

    def initialize(*args)
      @cleaner = ActiveSupport::BacktraceCleaner.new
      super
      after_initialize if respond_to? :after_initialize
    end

    # default JSON format is OK
    def create_formatter
      ::Ougai::Formatters::Bunyan.new
    end

    def report(message:, exception: nil, custom: {})
      report_type = exception.present? ? :error : :warn
      backtrace = exception.present? ? exception.backtrace : Thread.current.backtrace
      found, file, line_number, function = extract_stack_info(backtrace)
      custom_data = {
        matched_stack_trace: found, file: file, line_number: line_number, function: function
      }.merge(custom)

      send(report_type, message, custom_data: custom_data)
    end

    private

    def extract_stack_info(backtrace)
      match = RUBY_STACK_REGEX.match(@cleaner.clean(backtrace).first)
      found = match.present?
      return false unless found

      return found, match[:file], match[:line], match[:function]
    end
  end
end
