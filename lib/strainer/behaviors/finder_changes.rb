# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # Enables passing activerecord objects to finders which no longer works in Rails 6
    # eg. Profile.exists?(profile)
    class FinderChanges < Strainer::RuntimeBehavior
      module EnablePassingActiveRecordInstancesToUpdate
        include Strainer::Logable

        def update(id = :all, attributes)
          if id.is_a?(ActiveRecord::Base)
            id = id.id
            strainer_log('PASSING_ACTIVERECORD', custom: { method: 'klass.update' })
          end

          super(id, attributes)
        end
      end

      module EnablePassingActiveRecordInstancesToFinders
        include Strainer::Logable

        def exists?(conditions = :none)
          if conditions.is_a?(ActiveRecord::Base)
            conditions = conditions.id
            strainer_log('PASSING_ACTIVERECORD', custom: { method: 'exists?' })
          end

          super(conditions)
        end

        def find_one(id)
          if id.is_a?(ActiveRecord::Base)
            id = id.id
            strainer_log('PASSING_ACTIVERECORD', custom: { method: 'find_one' })
          end

          super(id)
        end
      end

      def apply_patch!
        ActiveRecord::Base.extend(EnablePassingActiveRecordInstancesToUpdate)
        ActiveRecord::Relation.prepend(EnablePassingActiveRecordInstancesToFinders)
      end
    end
  end
end
