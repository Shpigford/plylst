web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -e ${RAILS_ENV:-development} -C config/sidekiq.yml