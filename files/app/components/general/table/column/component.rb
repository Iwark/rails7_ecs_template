module General
  module Table
    module Column
      class Component < ViewComponent::Base
        def initialize(options = {})
          super()
          @class = options[:class]
        end

        def call
          tag.th(content,
                 class: "#{@class} text-left text-gray-600 px-4 py-2 bg-gray-200 " \
                        'text-sm')
        end
      end
    end
  end
end
