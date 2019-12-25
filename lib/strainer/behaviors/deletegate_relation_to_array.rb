# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    class DelegateRelationToArray < Strainer::RuntimeBehavior
      def patch; end
    end
  end
end
