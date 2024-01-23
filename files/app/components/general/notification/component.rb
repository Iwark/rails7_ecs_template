# frozen_string_literal: true

module General
  module Notification
    class Component < ViewComponent::Base
      def initialize(message:, type: nil)
        super()
        @message = message
        @type = type
      end

      private

      def controller_id = 'general--notification--component'

      def icon
        case @type.to_s
        when 'success'
          tag.i(class: 'fas fa-check-circle text-semantic-success')
        when 'alert'
          tag.i(class: 'fas fa-exclamation-triangle text-semantic-warning')
        when 'error'
          tag.i(class: 'fas fa-exclamation-triangle text-semantic-danger')
        else # notice
          tag.i(class: 'fas fa-exclamation-circle text-white')
        end
      end
    end
  end
end
