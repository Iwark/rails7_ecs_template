# frozen_string_literal: true

module General
  module Input
    module Label
      class Component < ViewComponent::Base
        def initialize(attribute:, text: nil, required: false, form: nil, **params)
          super
          @form = form
          @attribute = attribute
          @text = text
          @required = required
          @params = params
        end

        def render?
          @text != false
        end

        def call
          text = @text || default_text
          params = @params.dup
          params[:class] ||= default_classes.join(' ')
          tags = html_escape(text)
          tags << tag.small('(任意)', class: 'mx-1 pt-0.5') unless @required
          @form&.label(@attribute, tags, params) || label_tag(@attribute, tags, params)
        end

        private

        def default_text
          @form&.object&.class&.human_attribute_name(@attribute) || @attribute.capitalize
        end

        def default_classes
          %w[block mb-2 font-bold whitespace-nowrap text-sm text-natural-700
             group-[.error]:text-semantic-danger group-[.warning]:text-warning-400]
        end
      end
    end
  end
end
