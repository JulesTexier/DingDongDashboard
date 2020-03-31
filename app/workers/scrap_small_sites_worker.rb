class ScrapSmallSitesWorker
  include Sidekiq::Worker

  def perform(klass)
    puts klass
    scraper = klass.constantize.new
    puts scraper
    scraper.launch
  end

  def self.scrap
    scrapers.each_with_index do |scraper, index|
      perform_async(scraper.class.name)
    end
  end

  def self.scrapers
   return [ScraperEfficity.new, ScraperSuperImmo.new]
  end
end
