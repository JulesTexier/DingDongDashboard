source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.5.7"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.2", ">= 6.0.2.1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 4.1"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 4.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
gem "redis"
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

#ActiveRecord Bulk Insert made easy
gem 'activerecord-import'

gem "devise"
gem 'devise-jwt', '~> 0.1.0'
gem 'dry-configurable', '0.9.0'

gem "rubocop"

gem "rails_admin", "~> 2.0"

#Active Storage Backblaze
gem 'activestorage-backblaze'

# Use Active Storage variant
gem 'image_processing', '~> 0.2.3'
gem 'mini_magick', '~> 4.5', '>= 4.5.1'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Send HTTP REST requests
gem "typhoeus", "~> 1.1"

# Scrapping gems
gem "nokogiri"

# Better db print
gem "table_print"

# RSPEC
gem "rspec-retry"

# Postmark
gem "postmark-rails"

# Metrics
gem "chartkick"
gem "groupdate"

# Stripe
gem "stripe"

gem "rspec-rails", "~> 4.0.0.rc1"

gem "dotenv"


# Sidekiq
gem "sidekiq", "~> 4.1", ">= 4.1.2"

# CORS for webhook calls from website
gem "rack-cors", "~> 0.4.0"

gem "scout_apm"

gem "simple_form"

gem 'sprockets', '3.7.2'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rb-readline"
  gem "pry", "~> 0.12.2"
  gem "letter_opener"
  gem "rails_best_practices"

end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
  gem "shoulda-matchers", "~> 3.1", ">= 3.1.1"
  gem "nyan-cat-formatter"
  gem "database_cleaner-active_record"
  gem "rails-controller-testing"
  gem "webmock"
  gem "vcr"
  gem "timecop"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"
