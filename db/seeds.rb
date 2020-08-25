scraper_params = YAML.load_file("db/data/scraper_params.yml")

scraper_params.each do |param|
  param["params"].each do |data|
    s = ScraperParameter.new
    data["multi_page"] = false if data["multi_page"].nil?
    data["http_type"] = nil if data["http_type"].nil?
    data["http_request"] = [] if data["http_request"].nil?
    data["page_nbr"] = 1 if data["page_nbr"].nil?
    s.source = param["source"]
    s.zone = data["zone"]
    s.main_page_cls = data["main_page_cls"]
    s.scraper_type = data["scraper_type"]
    s.url = data["url"]
    s.multi_page = data["multi_page"]
    s.page_nbr = data["page_nbr"]
    s.http_type = data["http_type"]
    s.http_request = data["http_request"]
    s.group_type = data["group_type"]
    s.zone = data["zone"]
    if Rails.env.test?
      s.is_active = s.zone == "Paris (75)" ? data["is_active"] : false ## we don't want to run tests for every new city
    else
      s.is_active = data["is_active"]
    end
    if ScraperParameter.where(source: s.source, zone: s.zone, group_type: s.group_type, url: s.url).empty?
      if s.save
        puts "Insertion of parameters - #{s.source} - #{s.zone}"
      else
        puts "Error of parameter insertion"
      end
    end
  end
end

statuses_file = YAML.load(File.read("./db/data/statuses.yml"))

statuses_file.each do |status|
  if Status.where(name: status["name"]).empty?
    Status.create(name: status["name"], description: status["description"], status_type: status["status_type"])
    puts "Status - #{status["name"]} created"
  end
end

area_yaml = YAML.load_file("./db/data/areas.yml")
area_yaml.each do |district_data|
  district_data["datas"].each do |data|
    area = Area.find_by(name: data["name"])
    if area.nil?
      Area.create(name: data["name"], zone: district_data["zone"], zip_code: data["terms"].first)
      puts "Area - #{data["name"]} created"
    elsif area.zone != district_data["zone"]
      area.update(zone: district_data["zone"])
      puts "Area - #{data["name"]}'s zone updated"
    elsif area.zip_code != data["terms"].first
      area.update(zip_code: data["terms"].first)
      puts "Area - #{data["name"]}'s zip_code updated"
    end
  end
end

broker_shifts_yaml = YAML.load_file("./db/data/broker_shifts.yml")
broker_shifts_yaml.each do |shift|
  if BrokerShift.where(name: shift["name"]).empty?
    BrokerShift.create(shift)
  end
end

brokers_yaml = YAML.load_file("./db/data/brokers.yml")
brokers_yaml.each do |broker|
  if Broker.where(trello_id: broker["trello_id"]).empty?
    puts "Inserting #{broker["firstname"]}"
    Broker.create(broker)
  end
end

###################################################################
# Script de migration de la rentrée (v4) - Ete 2020 (first part)
###################################################################

### 1) Boucle sur tous les Subscribers 

Subscriber.all.each do |subscriber|

  # Migration des critères vers un objet Research
  research = Research.new(subscriber: subscriber)
  research.min_floor = subscriber.min_floor
  research.has_elevator = subscriber.min_elevator_floor.nil? ? false : true
  research.min_elevator_floor = subscriber.min_elevator_floor
  research.min_surface = subscriber.min_surface
  research.min_rooms_number = subscriber.min_rooms_number
  research.max_price = subscriber.max_price
  research.min_price = subscriber.min_price
  research.max_sqm_price = subscriber.max_sqm_price
  research.is_active = subscriber.is_active
  research.balcony = subscriber.balcony
  research.terrace = subscriber.terrace
  research.garden = subscriber.garden
  research.new_construction = subscriber.new_construction
  research.last_floor = subscriber.last_floor
  research.home_type = subscriber.home_type
  research.apartment_type = subscriber.apartment_type
  research.created_at = subscriber.created_at

  research.save

  # Migration des selected_areas vers des research_area
  subscriber.selected_areas.each do |sa|
    ResearchArea.create(research: research, area: sa.area)
  end

  # Migration des favoris vers des saved_properties
  subscriber.favorites.each do |fav|
    SavedProperty.create(research: research, property: fav.property)
  end

end


### 2 ) Boucle sur tous les hunters

HunterSearch.all.each do |hs|

# Migration des critères vers un objet Research
  research = Research.new(hunter: hs.hunter)

  research.min_floor = hs.min_floor
  research.has_elevator = hs.has_elevator
  research.min_elevator_floor = hs.min_elevator_floor
  research.min_surface = hs.min_surface
  research.min_rooms_number = hs.min_rooms_number
  research.max_price = hs.max_price
  research.min_price = hs.min_price
  research.max_sqm_price = hs.max_sqm_price
  research.is_active = hs.is_active
  research.balcony = hs.balcony
  research.terrace = hs.terrace
  research.garden = hs.garden
  research.new_construction = hs.new_construction
  research.last_floor = hs.last_floor
  research.home_type = hs.home_type
  research.apartment_type = hs.apartment_type
  research.created_at = hs.created_at
  
  research.save
  
# Migration des selected_areas vers des research_area
  hs.hunter_search_areas.each do |hsa|
    ResearchArea.create(research: research, area: hsa.area)
  end

# Migration des favoris vers des saved_properties
  hs.selections.each do |fav|
    SavedProperty.create(research: research, property: fav.property)
  end

end 



###################################################################
# Script de migration de la rentrée (v4) - Ete 2020 (second part)
###################################################################



# # Suppression de tous les favoris 
# Favorite.all.destroy_all

# # Suppression de toutes les selections 
# Selection.all.destroy_all

# # Suppression de toutes les selected_areas 
# SelectedArea.all.destroy_all

# # Suppression de toutes les hunter_search_areas 
# HunterSearchArea.all.destroy_all

# # Suppression de toutes les hunter_search 
# HunterSearch.all.destroy_all 

# # Suppresion de tous les leads
# Lead.all.destroy_akk