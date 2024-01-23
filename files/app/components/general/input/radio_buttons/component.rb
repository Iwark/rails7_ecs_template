# frozen_string_literal: true

module General
  module Input
    module RadioButtons
      class Component < General::Input::Component
        private

        def collection_tags
          collection = @options[:collection] || enum_collection
          collection.map do |label, value|
            tag.label(class: 'flex items-center gap-2') do
              radio_button(value) + tag.div(label, class: 'flex-1')
            end
          end
        end

        def radio_button(value)
          klass = 'w-6 h-6'
          checked = value == (@options[:value] || @form&.object&.send(@attribute))
          if @form.present?
            @form.radio_button(@attribute, value, checked:, class: klass, data: @options[:data])
          else
            radio_button_tag(@attribute, value, checked, class: klass, data: @options[:data])
          end
        end

        def radio_label(label, value)
          if @form.present?
            @form.label(@attribute, label)
          else
            label_tag("#{@attribute}_#{value}", label)
          end
        end

        def enum_collection
          return [] unless attribute_enum?

          obj_klass.send("#{@attribute.to_s.pluralize}_i18n").invert
        end
      end
    end
  end
end
