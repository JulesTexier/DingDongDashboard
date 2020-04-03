class ScrapRegularSitesWorker
  include Sidekiq::Worker

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
    RegularSites.constants.each do |element|
      instances.push(RegularSites.const_get(element).new)
    end
   return instances
  end
end
