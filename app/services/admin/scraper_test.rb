class Admin::ScraperTest < ApplicationService

  def test_scraper_params(sc_ids)
    results = []
    scope = ScraperParameter.where(id: sc_ids)
    areas_id = scope.map{|s| s.zone}.uniq.map{|z| Department.find_by(name: z).areas}.flatten.map{|a| a.id}
    scope.each do |sc|
      props = Property.where(source: sc.source, area: areas_id).where('created_at > ? ', Time.now - 1.hour).count
      result = [sc.id, sc.source, props]
      result.push(sc.url) if props == 0
      results.push(result)
      puts "RIEN SCRAPE POUR LE SCRAPER id : #" + sc.id.to_s if props ==  0
    end
    results
  end

end