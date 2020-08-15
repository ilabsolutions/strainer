# frozen_string_literal: true

module Strainer
  module Behaviors
    # This module adds the ability to use path helpers on mailers
    # This behavior was deprecated in https://github.com/rails/rails/commit/bd944e078d0f40e26d66b03da1449ff9cdcc101b
    # and later removed
    class MailerWithPathHelpers < Strainer::RuntimeBehavior
      module SupportsPath
        def supports_path?
          true
        end
      end

      module PathHelpersWithLogging
        def url_helpers(*args)
          mod = super
          wrapped_paths_module = wrap_module(mod)
          mod.prepend(wrapped_paths_module)
        end

        private

        # rubocop:disable Metrics/MethodLength this aint too long
        def wrap_module(mod)
          Module.new do
            include Strainer::Logable

            mod.instance_methods.each do |method|
              next unless method.to_s.ends_with?('_path')

              define_method(method) do |*arguments, &block|
                if instance_variable_defined?(:@_controller) && @_controller.is_a?(ActionMailer::Base)
                  strainer_log('PATH_HELPER_IN_MAILER', custom: { helper_method: __method__ })
                end
                super(*arguments, &block)
              end
            end
          end
        end
        # rubocop:enable Metrics/MethodLength
      end

      def apply_patch!
        ActionMailer::Base.singleton_class.prepend(SupportsPath)
        ActionDispatch::Routing::RouteSet.prepend(PathHelpersWithLogging)
      end
    end
  end
end
