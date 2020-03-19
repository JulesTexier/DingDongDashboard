RSpec.configure do |config|
<<<<<<< HEAD

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end
  
    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end
  
    config.before(:each, :js => true) do
      DatabaseCleaner.strategy = :truncation
    end
  
    config.before(:each) do
      DatabaseCleaner.start
    end
  
    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
=======
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: %w(ar_internal_metadata)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
>>>>>>> master
