require File.join(File.dirname(__FILE__), "../../config/environment")

namespace :scraper do
  desc "Raketasks for scrapers."

  task :regular do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperPap.new.extract_first_page
    ScraperFigaro.new.extract_first_page
    ScraperCentury.new.extract_first_page
    ScraperLogicImmo.new.extract_first_page
    ScraperSuperImmo.new.extract_first_page
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Regular Scraper script took #{ending - starting} seconds to run"
  end

  task :premium do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperLeBonCoin.new.extract_first_page
    ScraperSeLoger.new.extract_first_page
    ScraperMeilleursAgents.new.extract_first_page
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Premium Scraper script took #{ending - starting} seconds to run"
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

  task :good_morning do
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    Broadcaster.new.good_morning
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "The Good Morning Broadcaster script took #{ending - starting} seconds to run"
  end
end
