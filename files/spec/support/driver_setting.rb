Capybara.register_driver :remote_chrome do |app|
  url = ENV.fetch('SELENIUM_DRIVER_URL', nil)
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': {
      args: ['headless', 'window-size=1200,970', 'no-sandbox', 'disable-gpu', 'disable-dev-shm-usage']
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, url:, capabilities:)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, js: true, type: :system) do
    if ENV['SELENIUM_DRIVER_URL'].present?
      driven_by :remote_chrome
      Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
      Capybara.server_port = ENV.fetch('WEB_TEST_PORT', 4444)
      Capybara.server = :puma
      Capybara.run_server = true
      Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
    else
      driven_by :rack_test
    end
  end
end
