class ScraperLiberkeys < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_type, :http_request

  def initialize
    @url = "https://api.liberkeys.com/portal/properties?region=1&max_results=500&min_price=0&max_price=3500000&room_count=0&bedroom_count=0&include_sold_properties=false&order=recent_desc"
    @source = "Liberkeys"
    @main_page_cls = ""
    @type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @http_request = [{}, {}]
    @http_type = "get_json"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self)["properties"].each do |item|
      begin
        next if item["is_sold"] || item["is_unavailable"]
        next if !item["address"].downcase.include?("paris")
        hashed_property = {}
        hashed_property[:link] = "https://liberkeys.com/portails/" + item["slug"]
        hashed_property[:surface] = item["surface"].to_i
        hashed_property[:area] = regex_gen(item["address"], '(Paris)(.?)(\d+)').to_int_scrp.to_s.district_generator
        hashed_property[:rooms_number] = item["room_count"]
        hashed_property[:price] = item["price"].to_i
        if go_to_prop?(hashed_property, 7)
          property = fetch_json_get("https://api.liberkeys.com/portal/properties/#{item["slug"]}")
          hashed_property[:description] = property["description"]
          hashed_property[:bedrooms_number] = item["bedroom_count"]
          hashed_property[:flat_type] = item["type"]
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = regex_gen(property["floor"], '(\d)(\s)sur').to_int_scrp
          hashed_property[:has_elevator] = nil
          property["building_services"].each do |service|
            service == "Ascenseur" ? hashed_property[:has_elevator] = true : nil
          end
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:contact_number] = property["agent"]["phone"]
          hashed_property[:images] = item["low_quality_media"].each { |img| img.gsub!("//s3-eu-west-3", "https://s3-eu-west-3") }
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
