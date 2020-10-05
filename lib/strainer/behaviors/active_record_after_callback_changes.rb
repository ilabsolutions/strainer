# frozen_string_literal: true

module Strainer
  module Behaviors
    # This downgrades behavior of activerecord::dirty functions to rails 4 style
    # https://github.com/rails/rails/commit/16ae3db5a5c6a08383b974ae6c96faac5b4a3c81
    # After this behavior is loaded, functions like changed? and email_changed?
    # and email_was etc behave like rails 4.
    class ActiveRecordAfterCallbackChanges < Strainer::RuntimeBehavior
      module InterceptDirtyCalls
        def changed?
          binding.pry
          return saved_changes? if intercept_call?

          super
        end

        def changes
          return saved_changes if intercept_call?

          super
        end

        def attribute_changed?(attr_name, **options)
          binding.pry
          return saved_change_to_attribute?(attr_name, **options) if intercept_call?

          super
        end

        def attribute_was(attr_name)
          return attribute_before_last_save(attr_name) if intercept_call?

          super
        end

        private

        def intercept_call?
          in_app? && in_after_callback
        end

        def in_app?
          return true if Rails.env.development? || Rails.env.test?
          return false if Rails.root.blank?

          # skip first 3 frames. 2 from this patch and 1 from the attribute_methods code.
          method_call_location = caller[3][/[^:]+/]
          method_call_location.start_with?(Rails.root)
        end
      end

      module Rails4DirtyBehavior
        extend ActiveSupport::Concern

        included do
          prepend InterceptDirtyCalls
        end

        mattr_accessor :overridden_dirty_behavior, default: true

        attr_accessor :in_after_callback
      end

      module WithRails4Dirty
        def rails4_style_dirty
          include Rails4DirtyBehavior
        end
      end

      module CallbackBuilderChanges
        def apply(callback_sequence)
          return super unless kind == :after

          user_conditions = after_conditions_lambdas
          user_callback = ActiveSupport::Callbacks::CallTemplate.build(@filter, self)
          ActiveSupport::Callbacks::Filters::After.build(callback_sequence, user_callback.make_lambda(true), user_conditions, chain_config)
        end

        private

        def after_conditions_lambdas
          @if.map { |c| ActiveSupport::Callbacks::CallTemplate.build(c, self).make_lambda(true) } +
            @unless.map { |c| ActiveSupport::Callbacks::CallTemplate.build(c, self).inverted_lambda(true) }
        end
      end

      module CallTemplateChanges
        def make_lambda(after_callback = false)
          lambda do |target, value, &block|
            begin
              target, block, method, *arguments = expand(target, value, block)
              override_dirty = target.try(:overridden_dirty_behavior) || false
              if override_dirty
                old_flag = target.in_after_callback
                target.in_after_callback = true if after_callback
              end
              target.send(method, *arguments, &block)
            ensure
              target.in_after_callback = old_flag if override_dirty
            end
          end
        end

        def inverted_lambda(after_callback = false)
          lambda do |target, value, &block|
            begin
              target, block, method, *arguments = expand(target, value, block)
              override_dirty = target.try(:overridden_dirty_behavior) || false
              if override_dirty
                old_flag = target.in_after_callback
                target.in_after_callback = true if after_callback
              end
              !target.send(method, *arguments, &block)
            ensure
              target.in_after_callback = old_flag if override_dirty
            end
          end
        end
      end

      def apply_patch!
        ActiveRecord::Base.extend(WithRails4Dirty)
        ActiveSupport::Callbacks::Callback.prepend(CallbackBuilderChanges)
        ActiveSupport::Callbacks::CallTemplate.prepend(CallTemplateChanges)
      end
    end
  end
end
