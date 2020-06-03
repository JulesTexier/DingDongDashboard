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
    if ScraperParameter.where(source: s.source, zone: s.zone, group_type: s.group_type).count == 0
      if s.save
        puts "Insertion of parameters - #{s.source} - #{s.zone}"
      else
        puts "Error of parameter insertion"
      end
    end
  end
end

# referrals = [
#   {
#     firstname: "Mathieu",
#     lastname: "EM Reno",
#     email: "emtrinquart@gmail.com",
#     phone: "0698936051",
#     referral_type: "entrepreneur tout corps d'état",
#   },
#   {
#     firstname: "Gulay",
#     lastname: "Demirtas",
#     email: "gulay.demirtas@paris.notaires.fr",
#     phone: "0664720732",
#     referral_type: "notaire",
#   },
#   {
#     firstname: "Camille",
#     lastname: "Hermand",
#     email: "camille@camillearchitectures.com",
#     phone: "0682652785",
#     referral_type: "architecte",
#   },
#   {
#     firstname: "Ruth",
#     lastname: "Zola",
#     email: "rzola@agorafinance.fr",
#     phone: "0610592419",
#     referral_type: "chasseur immobilier",
#   }
# ]

# referrals.each do |referral|
#   Referral.create(firstname: referral[:firstname], lastname: referral[:lastname], email: referral[:email], phone: referral[:phone], referral_type: referral[:referral_type])
# end

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
    if Area.where(name: data["name"]).empty?
      Area.create(name: data["name"], zone: district_data["zone"])
      puts "Area - #{data["name"]} created"
    end
  end
end


broker_shifts_yaml = YAML.load_file("./db/data/broker_shifts.yml")
broker_shifts_yaml.each do |shift|
  if BrokerShift.where(name: shift[:name]).empty?
    BrokerShift.create(shift)
  end
end