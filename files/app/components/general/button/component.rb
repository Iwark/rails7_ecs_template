module General
  module Button
    class Component < ViewComponent::Base
      def initialize(title: nil, path: nil, color: :primary, size: :default, **options)
        super()
        @title = title
        @path = path
        @color = color
        @size = size
        @options = options
      end

      def call
        @options[:class] ||= "inline-block rounded #{color} #{size}"
        if @path.present?
          link_to(@title || content, @path, @options)
        else
          tag.button(@title || content, **@options)
        end
      end

      private

      def color
        {
          primary: 'bg-primary text-white hover:bg-primary-90 disabled:bg-gray-20',
          secondary: 'bg-white border border-gray-20 hover:bg-white-hover',
          alert: 'bg-semantic-alert text-white'
        }[@color] || ''
      end

      def size
        {
          large: 'w-72 h-12',
          small: 'py-2 px-3 min-w-[66px] text-center'
        }[@size] || 'py-2 px-4'
      end
    end
  end
end
