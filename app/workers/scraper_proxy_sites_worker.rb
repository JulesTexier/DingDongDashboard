class ScraperProxySitesWorker
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
    workers = Sidekiq::Workers.new
    tasks = workers.map {|_process_id, _thread_id, work| work["payload"]["args"] }
    scrapers.each do |scraper|
      perform_async(scraper.class.name) unless tasks.flatten.include?(scraper.class.name)
    end
  end

  def self.scrapers
    instances = []
    Proxy.constants.each do |element|
      instances.push(Proxy.const_get(element).new)
    end
    return instances
  end
end
