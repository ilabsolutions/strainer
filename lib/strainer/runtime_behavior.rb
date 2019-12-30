# frozen_string_literal: true

module Strainer
  # Base class that models initialization of patched rails behaviors
  class RuntimeBehavior
    attr_accessor :logger

    def self.init!
      fail "behavior class: #{self} is not setup with a monkeypatch" unless method_defined? :patch

      new.apply_patch!
    end

    def initialize
      local_logger ||= Strainer::Railtie.config.logger
      @logger = local_logger
    end
  end
end
