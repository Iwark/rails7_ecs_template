# frozen_string_literal: true

module General
  module Input
    module DatePicker
      class Component < General::Input::TextField::Component
        def initialize(attribute:, form: nil, **options)
          super(attribute:, form:, **options)

          @options[:icon_right] ||= 'fa-solid fa-calendar-days'
        end

        private

        def controller_id = 'general--input--date-picker--component'
      end
    end
  end
end
