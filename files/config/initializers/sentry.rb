Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.enabled_environments = %w[production staging]

  config.traces_sampler = lambda do |context|
    transaction_context = context[:transaction_context]
    op = transaction_context[:op]
    name = transaction_context[:name]

    case op
    when /http/
      case name
      when '/up'
        0.0
      else
        1.0
      end
    when /sidekiq/
      0.5
    else
      1.0
    end
  end
  config.profiles_sample_rate = 1.0
end
