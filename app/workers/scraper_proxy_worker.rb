class ScraperProxyWorker
  include Sidekiq::Worker

  def perform(klass, ids)
    scraper = klass.constantize.new(ids)
    puts "----"
    puts "Starting to scrap new properties from #{scraper.source} website"
    puts "----"
    scraper.launch
  end

  def self.scrap
    workers = Sidekiq::Workers.new
    tasks = workers.map {|_process_id, _thread_id, work| work["payload"]["args"] }
    scrapers.each do |scraper|
      hp_ids = Array.new()
      lp_ids = Array.new()
      scraper.params.each { |prm| prm.high_priority? ? hp_ids.push(prm.id) : lp_ids.push(prm.id) }
      hp_args = [scraper.class.name, hp_ids]
      lp_args = [scraper.class.name, lp_ids]
      self.set(queue: "high_level_scraper").perform_async(hp_args[0], hp_args[1]) unless tasks.include?(hp_args)
      self.set(queue: "low_level_scraper").perform_async(lp_args[0], lp_args[1]) unless tasks.include?(lp_args)
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