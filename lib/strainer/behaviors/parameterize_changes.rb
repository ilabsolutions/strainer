# frozen_string_literal: true

module Strainer
  module Behaviors
    class ParameterizeChanges < Strainer::RuntimeBehavior
      # Monkey patches calls to parameterize to allow calling this like rails 4
      # eg "Donald E. Knuth".parameterize('+') => "donald+e+knuth"
      # Rails 6 calls work as usual without logging
      # eg "Donald E. Knuth".parameterize => "donald-e-knuth"
      # eg "Donald E. Knuth".parameterize(separator: '+') => "donald+e+knuth"
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
