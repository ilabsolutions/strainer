# frozen_string_literal: true

require 'active_record'

module Strainer
  module Behaviors
    class DelegateRelationToArel < Strainer::RuntimeBehavior
      def patch; end
    end
  end
end
