module BetterRailsSystemTests
  def take_screenshot
    return super unless Capybara.last_used_session

    Capybara.using_session(Capybara.last_used_session) { super }
  end

  def image_path
    Pathname.new(absolute_image_path).relative_path_from(Rails.root).to_s
  end
end

RSpec.configure do |config|
  config.include BetterRailsSystemTests, type: :system

  config.around(:each, type: :system) do |ex|
    was_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.server_host
    ex.run
    Rails.application.default_url_options[:host] = was_host
  end

  config.prepend_before(:each, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
