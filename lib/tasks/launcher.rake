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

  task :independant do
    puts "Launching Independant Worker"
    ScraperIndependantSitesWorker.scrap
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
end

namespace :broadcast do
  desc "This is a task for broadcasting messages to our users."

  task :new_properties_gallery do
    puts "This will broadcast new scraped properties to active subscribers"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Broadcaster.new.new_properties_gallery
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The new_properties broadcast script took #{ending - starting} seconds to run"
  end

  task :good_morning do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Broadcaster.new.good_morning
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Good Morning Broadcaster script took #{ending - starting} seconds to run"
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
