if Rails.env.production?
  Raven.configure do |config|
    config.dsn = ENV['sentry_dsn']
    config.environments = ['production']
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.excluded_exceptions += ['RestClient::TooManyRequests', 'Net::OpenTimeout']
  end
end