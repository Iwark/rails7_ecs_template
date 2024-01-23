# frozen_string_literal: true

module General
  module Input
    module Select
      class Component < General::Input::Component
        def initialize(attribute:, form: nil, **options)
          super(attribute:, form:, **options)

          return if collection.present?

          @options[:disabled] = true
        end

        private

        def controller_id
          'general--input--select--component'
        end

        def select(html_options = {})
          if @form.nil?
            options = placeholder.present? ? [[placeholder, nil]] + collection : collection
            select_tag(@attribute,
                       options_for_select(options, **select_options),
                       html_options)
          else
            @form.select(@attribute, collection, select_options, html_options)
          end
        end

        def select_classes
          classes = %w[w-full py-2.5 min-h-[2.75rem] rounded bg-white appearance-none
                       border border-primary-50 focus:outline-none disabled:opacity-60
                       group-[.error]:border-semantic-danger group-[.warning]:border-warning-400]
          classes << 'px-4' if @options[:disabled]
          classes.join(' ')
        end

        def select_options
          options = {}
          value = @options[:selected] || @options[:value]
          options[:selected] = value if value.present?
          options[:include_blank] = @options[:include_blank] unless @form.nil?
          options[:prompt] = placeholder if @options[:disabled]
          options
        end

        def collection
          return @collection if @collection

          @collection = @options[:collection]
          @collection ||= enum_collection || []
          map_collection

          @collection
        end

        def map_collection
          if @options[:label_method] ||
             @options[:value_method] ||
             @collection.is_a?(ActiveRecord::Relation) ||
             @collection.is_a?(ActiveHash::Relation)
            @collection = @collection.map do |element|
              [element.try(label_method), element.try(value_method)]
            end
          end
        end

        def label_method
          @options[:label_method] || :to_s
        end

        def value_method
          @options[:value_method] || :id
        end

        def placeholder
          return super if collection.present?

          attr_name = obj_klass&.human_attribute_name(@attribute) || t('helpers.select.option')
          t('helpers.select.no_options', attr_name:)
        end
      end
    end
  end
end
