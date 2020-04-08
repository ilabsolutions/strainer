# frozen-string-literal: true

Dir[File.dirname(__FILE__) + '/behaviors/*.rb'].sort.each { |file| require file }

module Strainer
  # Loads patched behaviors in different rails components
  class Patches
    def self.setup!(component)
      case component
      when :action_controller
        load_behaviors Behaviors::ParametersAsHash
      when :active_record
        load_behaviors(
          Behaviors::AbstractMysqlAdapter,
          Behaviors::ForcedReloading,
          Behaviors::RelationDelegationChanges,
          Behaviors::FinderChanges,
          Behaviors::RelationQueryMethodChanges
        )
      end
    end

    def self.load_behaviors(*args)
      args.each(&:init!)
    end
  end
end
