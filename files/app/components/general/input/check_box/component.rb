module General
  module Input
    module CheckBox
      class Component < General::Input::Component
        def initialize(checked_value: nil, unchecked_value: nil, checked: false, **options)
          super(**options)
          @checked_value = checked_value || '1'
          @unchecked_value = unchecked_value
          @unchecked_value ||= '0' if @checked_value == '1'
          @checked = checked
        end

        def call
          tag.div(class: 'flex gap-2') do
            safe_join [check_box, label]
          end
        end

        private

        def check_box
          if @form.present?
            @form.check_box(@attribute, check_box_options, @checked_value, @unchecked_value)
          else
            check_box_tag(@attribute, @checked_value, @checked, check_box_options)
          end
        end

        def check_box_options
          {
            class: 'w-6 h-6',
            data: @options[:data],
            checked: @checked
          }
        end
      end
    end
  end
end
