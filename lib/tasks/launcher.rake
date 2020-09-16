require File.join(File.dirname(__FILE__), "../../config/environment")

namespace :scraper do
  desc "Raketasks for scrapers."

  task :hub do
    puts "Launching Hub Worker"
    ScraperHubSitesWorker.scrap
  end

  task :group do
    puts "Launching Group Worker "
    ScraperGroupSitesWorker.scrap
  end

  task :premium do
    puts "Launching Premium Worker"
    ScraperPremiumSitesWorker.scrap
  end

  task :proxy do
    puts "Launching Premium Worker"
    ScraperProxySitesWorker.scrap
  end

  task :independant do
    puts "Launching Independant Worker"
    ScraperIndependantSitesWorker.scrap
  end

  task :alert do
    puts "Scanning Property numbers to see if everything is fine"
    Scraper.new.scraped_property_checker
  end
end

namespace :subscriber do
  desc "All the tasks required for Subscribers Actions"

  task :reactivation do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Manychat.new.reactivate_inactive_subscribers
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Reactivation script took #{ending - starting} seconds to run"
  end

  task :deactivation do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Manychat.new.deactivate_unsubscribers
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Deactivation script took #{ending - starting} seconds to run"
  end
end

namespace :broadcast do
  desc "This is a task for broadcasting messages to our users."

  task :live_broadcast do
    puts "Launching Live Broadcast"
    BroadcasterWorker.perform_async('live_broadcast')
  end

  task :good_morning do
    puts "Launching Good Morning Broadcast"
    BroadcasterWorker.perform_async('good_morning')
  end

  task :hourly_check_hunters do
    puts "Launching Hunter Not Live Broadcast"
    BroadcasterWorker.perform_async('hunter_not_live')
  end
end

namespace :test do
  desc "This runs test"
  task :services do
    RSpec::Core::RakeTask.new(:spec) do |t|
      t.pattern = "spec/services/*/_spec.rb"
    end
    Rake::Task["spec"].execute
  end
end

namespace :broker do
  desc "Tasks related to brokers"
  task :good_morning_message do
    Broker.send_good_morning_message_leads
  end
end

namespace :migration do 
  desc "Tasks to migrate datas for major release"
  task :hunter_migration do 
    Migration.new.hunter_migration_to_research
  end
  task :subscriber_migration do 
    Migration.new.subscriber_migration_to_research
  end

  task :agglomeration_migration do 
    Migration.new.agglomeration_migration
  end
end