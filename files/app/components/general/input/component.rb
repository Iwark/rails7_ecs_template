# frozen_string_literal: true

module General
  module Input
    class Component < ViewComponent::Base
      def initialize(attribute:, form: nil, **options)
        super
        @attribute = attribute
        @form = form
        @options = options

        @type = options[:as] || options[:type] || default_type
        @validations = options[:validations] || default_validations
      end

      def call
        params = { form: @form, attribute: @attribute, **@options }
        case @type
        when :text then render TextArea::Component.new(**params)
        when :date then render DatePicker::Component.new(**params)
        when :radio_buttons then render RadioButtons::Component.new(**params)
        when :select then render Select::Component.new(**params)
        else render TextField::Component.new(**params)
        end
      end

      private

      def controller_id
        'general--input--component'
      end

      def default_type
        return :select if !@options[:collection].nil? || attribute_enum?
        return :string if @form.nil?

        obj_klass.attribute_types[@attribute.to_s].type || :string
      end

      def default_validations
        return [] if obj_klass.nil?

        validators.map do |validator|
          class_name = validator.class.name.demodulize
          class_name.underscore.sub('_validator', '')
        end
      end

      def obj_klass
        @obj_klass ||= @form&.object&.class
      end

      def validators
        @validators ||= obj_klass&.validators_on(@attribute) || []
      end

      def input_container(options = {}, &)
        options[:class] = "group #{options[:class]}"
        options[:data] ||= {}
        options[:data][:controller] ||= controller_id
        options[:data]["#{controller_id}-has-error-value"] = object_has_error
        options[:data]["#{controller_id}-validations-value"] = @validations

        tag.div(**options, &)
      end

      def object_has_error
        @form&.object&.errors.present?
      end

      def label(params = {})
        params[:for] = nil if !params.key?(:for) && @type == :date
        render General::Input::Label::Component.new(
          form: @form,
          attribute: @attribute,
          text: @options[:label],
          required: required?,
          **params
        )
      end

      def required?
        @options[:required] || @validations.include?('presence') || @form.nil?
      end

      def error_container
        tag.div(class: 'flex flex-col items-start', data: {
                  "#{controller_id}-target": 'errorContainer'
                })
      end

      def placeholder
        return nil if @options[:placeholder] == false
        return @options[:placeholder] if @options[:placeholder]
        return nil if @form.nil?

        key = "helpers.placeholder.#{obj_klass.name.underscore}.#{@attribute}"
        I18n.t(key, default: @type == :select ? '選択してください' : nil)
      end

      def attribute_enum?
        obj_klass.respond_to?(:defined_enums) &&
          obj_klass.defined_enums.key?(@attribute.to_s)
      end

      def enum_collection
        return nil unless attribute_enum?

        obj_klass.send("#{@attribute.to_s.pluralize}_i18n").invert
      end

      def merge_data(data = {})
        result = @options[:data] || {}
        result[:action] = [result[:action], data[:action]].compact.join(' ')
        data.merge(result)
      end
    end
  end
end
