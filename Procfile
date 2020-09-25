web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -q broadcaster -q mailers -q high_level_scraper -c $SIDEKIQ_CONCURRENCY -C config/sidekiq.yml 
low_prio_worker: bundle exec sidekiq -q low_level_scraper -q low -c $SIDEKIQ_CONCURRENCY -C config/sidekiq.yml