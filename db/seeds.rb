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
    s.high_priority = data["high_priority"] unless data["high_priority"].nil?
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


agglo_file = YAML.load_file("db/data/agglomeration.yml")
agglo_file.each do |agglo_data|
  agglo = Agglomeration.find_by(name: agglo_data["agglomeration"])
  if agglo.blank?
    a = Agglomeration.new
    a.name = agglo_data["agglomeration"]
    a.image_url = agglo_data["image_url"]
    a.is_active = agglo_data["is_active"]
    a.save
    agglo_data["zone"].each do |department|
      Department.create(name: department, agglomeration: a) unless Department.where(name: department).any?
    end
  else
    agglo_data["zone"].each do |department|
      Department.create(name: department, agglomeration: agglo) unless Department.where(name: department).any?
    end
  end
end

area_yaml = YAML.load_file("./db/data/areas.yml")
area_yaml.each do |district_data|
  district_data["datas"].each do |data|
    area = Area.find_by(name: data["name"])
    if area.nil?
      Area.create(name: data["name"], zone: district_data["zone"], zip_code: data["terms"].first, department: Department.find_by(name: district_data["zone"]))
      puts "Area - #{data["name"]} created"
    else 
      area.update(zone: district_data["zone"]) if area.zone != district_data["zone"]
      area.update(department: Department.find_by(name: area.zone)) if area.department.nil?
      area.update(zip_code: data["terms"].first) if area.zip_code != data["terms"].first
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
  b = Broker.find_by(trello_id: broker["trello_id"])
  if b.nil?
    puts "Inserting #{broker["firstname"]}"
    b = Broker.create(broker.except("agglomeration"))
  end
  # b.update(agglomeration: Agglomeration.find_by(name: broker["agglomeration"])) unless broker["agglomeration"].nil?
end

Notary.create(firstname: "Pierre-Alexis", lastname: "Leray") if Notary.all.empty?

Contractor.create(firstname: "Matthieu") if Contractor.all.empty?