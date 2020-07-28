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

    CODE_DIRS = %r{/(lib|spec|app|engines)/}.freeze

    class BunyanFormatterWithSilencedTimestamp < ::Ougai::Formatters::Bunyan
      def convert_time(data)
        data[:time] = ''
        data[:name] = ''
        data[:pid] = ''
      end
    end

    def initialize(*args)
      @cleaner = initialize_backtrace_cleaner
      super
      after_initialize if Rails::VERSION::MAJOR < 6 && respond_to?(:after_initialize)
    end

    # default JSON format is OK
    def create_formatter
      BunyanFormatterWithSilencedTimestamp.new
    end

    def report(message:, exception: nil, custom: {})
      report_type = exception.present? ? :error : :warn
      backtrace = exception.present? ? exception.backtrace : Thread.current.backtrace
      found, trace, file, line_number, function = extract_stack_info(backtrace)
      custom_data = {
        matched_stack_trace: found, file: file, line_number: line_number, function: function, trace: trace
      }.merge(custom)

      send(report_type, message, custom_data: custom_data)
    end

    private

    def initialize_backtrace_cleaner
      cleaner = ActiveSupport::BacktraceCleaner.new
      cleaner.add_filter { |line| line.gsub(Rails.root.to_s, '') }
      cleaner.add_silencer { |line| line =~ %r{strainer/lib} }
      cleaner.add_silencer { |line| line =~ %r{/\.rbenv} }
      cleaner
    end

    def clean_backtrace(backtrace)
      stack_frames = @cleaner.clean(backtrace)
      stack_frames.uniq { |frame| frame.split(CODE_DIRS)[1] }
    end

    def extract_stack_info(backtrace)
      trace = clean_backtrace(backtrace)
      match = RUBY_STACK_REGEX.match(trace.first)
      found = match.present?
      return false, trace unless found

      return found, trace, match[:file], match[:line], match[:function]
    end
  end
end
