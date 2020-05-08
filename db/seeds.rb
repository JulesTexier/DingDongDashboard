# Admin.create(firstname: "Etienne", lastname: "Chevalier", email: "etienne@hellodingdong.com", password: "DingDongRocks75$")
# Admin.create(firstname: "Frederic", lastname: "Bonnand", email: "fred@hellodingdong.com", password: "DingDongRocks75$")
# Admin.create(firstname: "Nicolas", lastname: "Fernandez-Le Follic", email: "nicolas@hellodingdong.com", password: "DingDongRocks75$")
# Admin.create(firstname: "Maxime", lastname: "Le Segretain", email: "maxime@hellodingdong.com", password: "DingDongRocks75$")
# Admin.create(firstname: "Greg", lastname: "Rouxel Oldrà", email: "greg@hellodingdong.com", password: "DingDongRocks75$")

# scraper_params = YAML.load_file("db/data/scraper_params.yml")

# scraper_params.each do |param|
#   param["params"].each do |data|
#     s = ScraperParameter.new
#     data["multi_page"] = false if data["multi_page"].nil?
#     data["http_type"] = nil if data["http_type"].nil?
#     data["http_request"] = [] if data["http_request"].nil?
#     data["page_nbr"] = 1 if data["page_nbr"].nil?
#     s.source = param["source"]
#     s.zone = data["zone"]
#     s.main_page_cls = data["main_page_cls"]
#     s.scraper_type = data["scraper_type"]
#     s.url = data["url"]
#     s.multi_page = data["multi_page"]
#     s.page_nbr = data["page_nbr"]
#     s.http_type = data["http_type"]
#     s.http_request = data["http_request"]
#     s.group_type = data["group_type"]
#     s.zone = data["zone"]
#     if ScraperParameter.where(source: s.source, zone: s.zone).count == 0 
#       if s.save
#         puts "Insertion of parameters - #{s.source} - #{s.zone}"
#       else
#         puts "Error of parameter insertion"
#       end
#     end
#   end
# end


