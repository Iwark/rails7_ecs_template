module General
  module Table
    module Row
      class Component < ViewComponent::Base
        def initialize(size: :default, **options)
          super()
          @size = size
          @options = options
        end

        def call
          classes = @options[:class] ? [@options[:class]] : []
          classes << 'group border-primary-50 border-b [&:last-of-type]:border-none'
          classes << 'small-row' if @size == :small
          @options[:class] = classes.join(' ')
          tag.tr(content, **@options)
        end
      end
    end
  end
end
