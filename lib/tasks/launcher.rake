require File.join(File.dirname(__FILE__), '../../config/environment')

namespace :scraper do
    desc "This take does something useful!"
  
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
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "The Premium Scraper script took #{ending - starting} seconds to run"
    end
  end
  
  namespace :broadcast do 
    desc "This is a task for broadcasting messages to our users."
  
    task :regular do 
      puts "We are launching a basic broadcast with new properties"
    end
  
    task :good_morning do 
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Broadcaster.new.good_morning
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "The Good Morning Broadcaster script took #{ending - starting} seconds to run"
    end
  end 