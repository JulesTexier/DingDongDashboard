class Launcher

    def regular_scrap
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      ScraperPap.new.extract_first_page
      ScraperFigaro.new.extract_first_page
      ScraperCentury.new.extract_first_page
      ScraperLogicImmo.new.extract_first_page
      ScraperSuperImmo.new.extract_first_page
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "The Regular Scraper script took #{ending - starting} seconds to run"
    end
  
    def premium_scrap
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      ScraperLeBonCoin.new.extract_first_page
      ScraperSeLoger.new.extract_first_page
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "The Premium Scraper script took #{ending - starting} seconds to run"
    end
  
    def good_morning_message
  
    end
  
    def death_window
  
    end
  
    private 
  
    def get_active_subscribers_hash
  
    end
  
  end 