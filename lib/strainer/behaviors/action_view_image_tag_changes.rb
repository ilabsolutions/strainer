# frozen_string_literal: true

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
        ActionView::Base.prepend(HandleNilImageTagSrc)
      end
    end
  end
end
