class ScraperWorker
  include Sidekiq::Worker

  def perform(klass, id)
    scraper = klass.constantize.new(id)
    puts "----"
    puts "Starting to scrap new properties from #{scraper.source} website"
    puts "----"
    scraper.launch
  end

  def self.scrap(scraper_module)
    workers = Sidekiq::Workers.new
    tasks = workers.map {|_process_id, _thread_id, work| work["payload"]["args"] }
    scrapers(scraper_module).each do |scraper|
      scraper.params.each do |param|
        selected_queue = param.high_priority ? "high_level_scraper" : "low_level_scraper"
        args = [scraper.class.name, param.id]
        Sidekiq::Client.push({'class' => self, 'queue' => selected_queue, 'args' => args}) unless tasks.include?(args)
      end
    end
  end

  def self.scrapers(scraper_module)
    instances = []
    scraper_module.constants.each do |element|
      instances.push(scraper_module.const_get(element).new)
    end
    instances
  end
end
