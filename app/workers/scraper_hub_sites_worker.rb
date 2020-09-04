class ScraperHubSitesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :scraper

  def perform(klass)
    scraper = klass.constantize.new
    puts "----"
    puts "Starting to scrap new properties from #{scraper.source} website"
    puts "----"
    scraper.launch
  end

  def self.scrap
    scrapers.each do |scraper|
      perform_async(scraper.class.name)
    end
  end

  def self.scrapers
    instances = []
    Hub.constants.each do |element|
      instances.push(Hub.const_get(element).new)
    end
   return instances
  end
end
