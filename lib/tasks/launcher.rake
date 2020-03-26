require File.join(File.dirname(__FILE__), "../../config/environment")

namespace :scraper do
  desc "Raketasks for scrapers."

  task :regular do
    puts "Launching Regular Scraper"
    puts "...\n\n"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperPap.new.launch
    ScraperFigaro.new.launch
    ScraperCentury.new.launch
    ScraperLogicImmo.new.launch
    ScraperSuperImmo.new.launch
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "\nThe Regular Scraper script took #{ending - starting} seconds to run"
  end

  task :dynamic do
    puts "Launching Dynamic Scraper"
    puts "...\n\n"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperOrpi.new.launch
    ScraperBienIci.new.launch
    ScraperKmi.new.launch
    ScraperLesParisiennesImmo.new.launch
    ScraperMorissImmobilier.new.launch
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "\nThe Dynamic Scraper script took #{ending - starting} seconds to run"
  end

  task :premium do
    puts "Launching Premium Scraper"
    puts "...\n\n"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperLeBonCoin.new.launch
    ScraperSeLoger.new.launch
    ScraperMeilleursAgents.new.launch
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "\nThe Premium Scraper script took #{ending - starting} seconds to run"
  end

  task :small_site do
    puts "Launching Small Shitty Website Scraper"
    puts "...\n\n"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ScraperGuyHoquet.new.launch
    ScraperFoncia.new.launch
    ScraperKmi.new.launch
    ScraperImax.new.launch
    ScraperEfficity.new.launch
    ScraperGreenAcres.new.launch
    ScraperAssasImmo.new.launch
    ScraperLesParisiennesImmo.new.launch
    ScraperCallImmo.new.launch
    ScraperDeferla.new.launch
    ScraperLaforet.new.launch

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "\nThe Small Shitty Website Scraper script took #{ending - starting} seconds to run"
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
    # puts "The new_properties broadcast script sent #{data[0]} properties for a total of #{data[1]} sendings"
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
