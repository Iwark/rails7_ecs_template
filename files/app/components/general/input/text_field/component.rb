# frozen_string_literal: true

module General
  module Input
    module TextField
      class Component < General::Input::Component
        private

        def text_field(params = {})
          @form&.text_field(@attribute, params) ||
            text_field_tag(@attribute, @options[:value], params)
        end

        def id_option
          @options[:id] ? { id: @options[:id] } : {}
        end

        def value_option
          @options[:value] ? { value: @options[:value] } : {}
        end
      end
    end
  end
end
