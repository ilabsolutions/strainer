# frozen_string_literal: true

module Strainer
  # Base class that models initialization of patched rails behaviors
  class RuntimeBehavior
    attr_accessor :logger

    def self.init!
      fail "behavior class: #{self} is not setup with a monkeypatch" unless method_defined? :patch

      new.patch
    end

    def initialize(custom_logger: Strainer::Railtie.config.logger)
      @logger = custom_logger
    end
  end
end
