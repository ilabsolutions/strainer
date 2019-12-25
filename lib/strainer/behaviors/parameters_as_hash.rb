# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    class ParametersAsHash < Strainer::RuntimeBehavior
      module BehavesHashlike
        HASH_INSTANCE = {}.freeze

        def method_missing(method_name, *args, &block)
          if HASH_INSTANCE.respond_to?(method_name)
            hash = to_h
            # TODO: Add logging here
            hash.send(method_name, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          HASH_INSTANCE.respond_to?(method_name) || super
        end
      end

      def patch
        ActionController::Parameters.prepend BehavesHashlike
      end
    end
  end
end
