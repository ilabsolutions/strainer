# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # This module re-adds the 'aliases' (uniq and uniq!) on an active record relation that were removed in rails 6
    # It logs usages so that the code can be later corrected.
    class RelationQueryMethodChanges < Strainer::RuntimeBehavior
      module ReAliasUniqToDistinct
        include Strainer::Logable

        def uniq(value = true)
          strainer_log('RELATION_UNIQ', custom: { relation_method: 'uniq' })
          distinct(value)
        end

        def uniq!(value = true)
          strainer_log('RELATION_UNIQ!', custom: { relation_method: 'uniq!' })
          distinct!(value)
        end
      end

      def apply_patch!
        ActiveRecord::Relation.include(ReAliasUniqToDistinct)
      end
    end
  end
end
