# frozen_string_literal: true

require 'action_view/helpers/asset_tag_helper'

module Strainer
  module Behaviors

    class ActionViewImageTagChanges < Strainer::RuntimeBehavior
      module HandleNilImageTagSrc
        def image_tag(source, options={})
          return tag("img", options) if source.nil?

          super
        end
      end

      def apply_patch!
        ActionView::Helpers::AssetTagHelper.prepend(HandleNilImageTagSrc)
      end
    end
  end
end
