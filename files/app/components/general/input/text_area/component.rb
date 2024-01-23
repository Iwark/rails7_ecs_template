# frozen_string_literal: true

module General
  module Input
    module TextArea
      class Component < General::Input::Component
        private

        def controller_id
          'general--input--text-area--component'
        end

        def text_area(options = {})
          options[:rows] ||= 8
          @form.text_area(@attribute, options)
        end

        def max_length
          return nil if @form.nil?

          length_validator = validators.find do |v|
            v.class.name.demodulize == 'LengthValidator'
          end
          return nil if length_validator.nil?

          length_validator.options[:maximum]
        end
      end
    end
  end
end
