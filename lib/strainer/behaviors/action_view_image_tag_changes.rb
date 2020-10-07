# frozen_string_literal: true

require 'action_view/helpers/asset_tag_helper'

module Strainer
  module Behaviors

    class ActionViewImageTagChanges < Strainer::RuntimeBehavior
      module HandleNilImageTagSrc
        include Strainer::Logable

        def image_tag(source, options={})
          if source.nil?
            strainer_log('IMAGE_TAG_SOURCE_NIL', custom: { source: source, options: options })
            return tag("img", options)
          end

          super
        end
      end

      def apply_patch!
        ActionView::Helpers::AssetTagHelper.prepend(HandleNilImageTagSrc)
      end
    end
  end
end
