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

      module EnablePassingActiveRecordInstancesToUpdateAll
        def update_all(updates)
          if updates.is_a?(Hash)
            updates.transform_values! do |value|
              ar_detected = value.is_a?(ActiveRecord::Base)
              strainer_log('PASSING_ACTIVERECORD', custom: { method: 'update_all' })
              ar_detected ? value.id : value
            end
          end

          super(updates)
        end
      end

      def apply_patch!
        ActiveRecord::Base.extend(EnablePassingActiveRecordInstancesToUpdate)
        ActiveRecord::Relation.prepend(EnablePassingActiveRecordInstancesToFinders)
        ActiveRecord::Relation.prepend(EnablePassingActiveRecordInstancesToUpdateAll)
      end
    end
  end
end
