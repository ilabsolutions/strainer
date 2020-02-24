# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # Allows Hash methods to be called on an ActionController::Parameters object which no longer
    # works in rails 6 since it doesn't descend from Hash.
    # params.merge(default_params)
    # For unsafe methods such as merge! we modify the internal params hash
    class ParametersAsHash < Strainer::RuntimeBehavior
      module BehavesHashlike
        include Strainer::Logable
        HASH_INSTANCE = {}.freeze
        UNSAFE_METHODS = %i[select! filter! reject! compact! transform_keys! transform_values! merge!].freeze
        private_constant :HASH_INSTANCE, :UNSAFE_METHODS

        def method_missing(method_name, *args, &block)
          return super unless forwardable?(method_name)

          strainer_log('PARAMS_AS_HASH', custom: { hash_method: method_name, unsafe: unsafe?(method_name) })

          # This method always returns a hash and not ActionController::Parameters.
          # This is on purpose since we're assuming that if you are using an action that treats the params as hash
          # AND are using the return value, then you actually are currently handling of the return as a hash.
          # Since we use strainer only until we can fix the rails compatibility issues, this should be ok to do.
          target_hash.send(method_name, *args, &block)
        end

        def respond_to_missing?(method_name, include_private = false)
          forwardable?(method_name) || super
        end

        private

        def target_hash(method_name)
          # only allow a whitelisted list of unsafe methods to operate on the internal parameters hash
          unsafe?(method_name) ? @parameters : to_h
        end

        def unsafe?(method_name)
          UNSAFE_METHODS.include?(method_name)
        end

        def forwardable?(method_name)
          # forwardable only if hash responds to a public method
          HASH_INSTANCE.respond_to?(method_name)
        end
      end

      def apply_patch!
        ActionController::Parameters.prepend BehavesHashlike
      end
    end
  end
end
