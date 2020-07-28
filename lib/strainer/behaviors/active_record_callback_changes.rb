# frozen_string_literal: true

require 'active_support/core_ext/module/delegation'

module Strainer
  module Behaviors
    # This module terminates callback chains when any of callbacks returns false.
    # This mimics rails 4 behavior. In rails > 5 the way to halt a callback chain
    # is to throw :abort. In rails 4 one could return false from a callback to terminate
    # the callback chain.
    class ActiveRecordCallbackChanges < Strainer::RuntimeBehavior
      module RedefineCallbacks
        extend ActiveSupport::Concern

        CALLBACKS = {
          before: %I[save create update destroy validation],
          after: %I[save create update destroy find initialize touch destroy validation],
          around: %I[save create update destroy]
        }.freeze

        METHOD_PREFIX = '__strainer_wrapped_method_'

        included do
          CALLBACKS.each do |type, hooks|
            hooks.each do |hook|
              callback_name = "#{type}_#{hook}"
              define_singleton_method(callback_name) do |*args, **options, &block|
                callback_arg = args[0]
                binding.pry if block&.source_location&.first&.include?("equipment.rb")
                args[0] = wrap_callback(callback_arg) if can_intercept_callback?(callback_arg)
                wrapped_block = wrap_callback_proc(block) if can_intercept_callback_block?(block)
                super(*args, **options, &wrapped_block)
              end
            end
          end

          delegate :unwrapped_method_name, to: :class
          delegate :from_app?, to: :class
        end

        # rubocop:disable Metrics/BlockLength
        class_methods do
          def from_app?(callback_arg)
            callback_arg = instance_method(callback_arg) if callback_arg.is_a?(Symbol)
            app_path = Rails.root.to_s
            callback_location = callback_arg.source_location&.first
            return false if callback_location.nil?

            callback_location.start_with?(app_path)
          end

          def unwrapped_method_name(method_name)
            method_name.to_s.split(METHOD_PREFIX).last.to_sym if method_wrapped?(method_name)
          end

          private

          def can_intercept_callback_block?(block)
            block.present? && from_app?(block)
          end

          def can_intercept_callback?(callback_arg)
            return false unless callback_arg.present?
            return can_intercept_callback_block?(callback_arg) if callback_arg.is_a?(Proc)

            !method_wrapped?(callback_arg)
          end

          def wrap_callback_proc(block)
            proc do
              callback_result = instance_exec(&block)
              strainer_log('CALLBACK_HALTING_ON_FALSE', custom: { source: 'callback proc' }) if callback_result == false
              throw(:abort) if callback_result == false
            end
          end

          def wrap_callback(callback_arg)
            return wrap_callback_proc(callback_arg) if callback_arg.is_a? Proc

            callback_method = wrapped_method_name(callback_arg)
            define_wrapped_callback(callback_method) if callback_method

            callback_method || callback_arg
          end

          def define_wrapped_callback(callback_method)
            define_method(callback_method) do
              method_name = unwrapped_method_name(__method__)
              callback_result = send(method_name) if method_name
              halt_callbacks = (callback_result == false && from_app?(method_name))
              strainer_log('CALLBACK_HALTING_ON_FALSE', custom: { source: 'callback method' }) if halt_callbacks
              throw(:abort) if halt_callbacks
              callback_result
            end
          end

          def wrapped_method_name(method_name)
            "#{METHOD_PREFIX}#{method_name}".to_sym
          end

          def method_wrapped?(method_name)
            method_name.to_s.start_with?(METHOD_PREFIX)
          end
        end
        # rubocop:enable Metrics/BlockLength
      end

      module WithInterceptedCallbacks
        def intercept_rails4_callbacks
          include Strainer::Logable
          include RedefineCallbacks
        end
      end

      def apply_patch!
        ActiveRecord::Base.extend(WithInterceptedCallbacks)
      end
    end
  end
end
