# frozen_string_literal: true

module Strainer
  module Behaviors

    class ParameterizeChanges < Strainer::RuntimeBehavior
      module Rails4StyleParameterize
        include Strainer::Logable

        def parameterize(*args)
          return super if args.first.is_a?(Hash) || args.blank?

          strainer_log('OLD_PARAMETERIZE')
          super(separator: args.first)
        end
      end

      def apply_patch!
        String.prepend(Rails4StyleParameterize)
      end
    end
  end
end
