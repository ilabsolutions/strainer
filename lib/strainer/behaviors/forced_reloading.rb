# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    # Allows reloading relations/association like company.employees(true) which works in
    # rails 4 but doesn't in rails 6. Rails 6 way is to call company.employees.reload
    class ForcedReloading < Strainer::RuntimeBehavior
      module DefineReaders
        # this method changed in 5.2.0 to strip arguments
        # See commit 39f6c6c641f0c92c532e0c3747d1536af657920f
        def define_readers(mixin, name)
          mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}(*args)
              association(:#{name}).reader(*args)
            end
          CODE
        end
      end

      module Reader
        include Strainer::Logable

        def reader(force_reload = false)
          if force_reload
            strainer_log('FORCE_RELOAD',
                         custom: {
                           association_name: reflection.name
                         })
          end
          klass.uncached { reload } if force_reload && klass
          super()
        end
      end

      def apply_patch!
        ActiveRecord::Associations::Builder::Association.singleton_class.prepend(DefineReaders)
        ActiveRecord::Associations::SingularAssociation.prepend Reader
        ActiveRecord::Associations::CollectionAssociation.prepend Reader
      end
    end
  end
end
