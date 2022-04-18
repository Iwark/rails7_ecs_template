Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.ignore_actions = ['OkComputer::OkComputerController#show']
end