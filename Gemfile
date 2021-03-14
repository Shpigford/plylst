source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

gem 'rails', '~> 6.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem "active_model_serializers"
gem 'storext'
gem 'bootstrap'
gem 'jquery-rails'
gem 'textacular', '~> 5.0'
gem 'with_advisory_lock'
gem 'activerecord-import'

# Webserver
gem "puma"
gem "puma_worker_killer"

# User Authentication
gem 'devise'
gem 'omniauth'
gem 'omniauth-spotify'

# Background Processing
gem "sidekiq"
gem "sidekiq-throttled"
gem "sidekiq-cron"
gem "sidekiq-unique-jobs"
gem "sidekiq-failures"

# Misc
gem 'figaro'
gem 'rspotify', git: 'https://github.com/Shpigford/rspotify'
gem 'sentry-raven'
gem "genius"
gem 'nokogiri'
gem 'httparty'
gem "colorize"          # ability to colorize output strings
gem "skylight"
gem "hashid-rails", "~> 1.0" # Slightly obfuscated playlist IDs
gem 'scout_apm'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'dalli'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem "binding_of_caller"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "foreman", require: false
  gem "annotate", require: false
  gem "better_errors"
  gem 'bullet'
  gem "letter_opener"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
