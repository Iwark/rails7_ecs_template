# frozen_string_literal: true

module General
  module Table
    class Component < ViewComponent::Base
      def initialize(**options)
        super()
        @options = options
      end
    end
  end
end
