# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # Allows Hash methods to be called on an ActionController::Parameters object which no longer
    # works in rails 6 since it doesn't descend from Hash.
    # params.merge(:params)
    class ParametersAsHash < Strainer::RuntimeBehavior
      module BehavesHashlike
        include Strainer::Logable
        HASH_INSTANCE = {}.freeze

        def method_missing(method_name, *args, &block)
          if HASH_INSTANCE.respond_to?(method_name)
            # create a hash copy so that unsafe methods can't be called on the internal hash.
            hash = to_h
            strainer_log('PARAMS_AS_HASH', custom: { hash_method: method_name })
            hash.send(method_name, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          HASH_INSTANCE.respond_to?(method_name) || super
        end
      end

      def apply_patch!
        ActionController::Parameters.prepend BehavesHashlike
      end
    end
  end
end
