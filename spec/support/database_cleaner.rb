RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: %w(ar_internal_metadata scraper_parameters)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :truncation, {:except => %w[scraper_parameters]}
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end