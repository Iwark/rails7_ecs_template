class AppComponent < ViewComponent::Base
  include ApplicationHelper
  include Turbo::FramesHelper

  protected

  def data(*params)
    actions = params.pluck(:action).compact

    tag.attributes(
      data: {}.merge(*params).merge(action: actions.join(' ')).filter { |_, v| v.present? }
    )
  end

  def data_value(controller, key, value)
    { "#{controller}-#{key}-value": value }
  end

  def data_target(controller, value)
    { "#{controller}-target": value }
  end

  def data_param(controller, param, value)
    { "#{controller}-#{param}-param": value }
  end

  def data_action(controller, action, trigger: nil)
    trigger_with_arrow = trigger ? "#{trigger}->" : ''
    { action: "#{trigger_with_arrow}#{controller}##{action}" }
  end
end
