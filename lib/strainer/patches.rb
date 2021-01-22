# frozen-string-literal: true

Dir[File.dirname(__FILE__) + '/behaviors/*.rb'].sort.each { |file| require file }

module Strainer
  # Loads patched behaviors in different rails components
  class Patches
    # rubocop:disable Metrics/MethodLength
    def self.setup!(component)
      case component
      when :action_controller
        load_behaviors(
          Behaviors::ParametersAsHash,
          Behaviors::ParameterizeChanges
        )
      when :active_record
        load_behaviors(
          Behaviors::AbstractMysqlAdapter,
          Behaviors::ForcedReloading,
          Behaviors::RelationDelegationChanges,
          Behaviors::FinderChanges,
          Behaviors::RelationQueryMethodChanges,
          Behaviors::ActiveRecordBeforeCallbackChanges
        )
      when :action_mailer
        load_behaviors(
          Behaviors::MailerWithPathHelpers
        )
      when :action_view
        load_behaviors(
          Behaviors::ActionViewImageTagChanges
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def self.load_behaviors(*args)
      args.each(&:init!)
    end
  end
end
