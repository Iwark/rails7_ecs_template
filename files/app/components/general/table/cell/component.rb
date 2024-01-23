module General
  module Table
    module Cell
      class Component < ViewComponent::Base
        def initialize(options = {})
          super()
          @width = options[:width]
          @tag = options[:tag] == :th ? :th : :td
          @data = options[:data] || {}
        end

        def call
          tag.try(@tag, content,
                  class: cell_class,
                  width: @width,
                  data: @data)
        end

        private

        def cell_class
          classes = 'px-2 py-4 text-sm first:pl-4 last:pr-4 group-[.small-row]:py-2'.split
          classes += if @tag == :th
                       %w[font-bold text-left border-b border-primary-50]
                     else
                       %w[font-normal break-words]
                     end
          classes.join(' ')
        end
      end
    end
  end
end
