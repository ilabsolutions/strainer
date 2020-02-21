# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # THIS PATCH IS UNSAFE FOR PRODUCTION!!!
    # I have removed the check for BLACKLISTED_ARRAY_METHODS since we want to catch all possible array methods being called
    # BLACKLISTED_ARRAY_METHODS = [
    #   :compact!, :flatten!, :reject!, :reverse!, :rotate!, :map!,
    #   :shuffle!, :slice!, :sort!, :sort_by!, :delete_if,
    #   :keep_if, :pop, :shift, :delete_at, :select!
    # ].to_set
    # This behavior makes AR relations behave like arrays.
    # eg. company.employees.compact
    class RelationDelegationChanges < Strainer::RuntimeBehavior
      module ReAddDeprecatedDelegations
        include Strainer::Logable

        private

        def array_delegable?(method)
          Array.method_defined?(method)
        end

        def arel_delegable?(method)
          arel&.respond_to?(method)
        end

        def method_missing(method, *args, &block)
          if array_delegable?(method)
            strainer_log('RELATION_AS_ARRAY', custom: { array_method: method })
            # we're cloning the records array since unsafe methods can be called against the array
            records.dup.public_send(method, *args, &block)
          elsif arel_delegable?(method)
            strainer_log('RELATION_AS_AREL', custom: { arel_method: method })
            arel.public_send(method, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          array_delegable?(method_name) || arel_delegable?(method_name) || super
        end
      end

      def apply_patch!
        ActiveRecord::Delegation::ClassSpecificRelation.include(ReAddDeprecatedDelegations)
      end
    end
  end
end
