class Independant::ScraperLiberkeys < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Liberkeys"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args)["properties"].each do |item|
        begin
          next if item["is_sold"] || item["is_unavailable"]
          next if !item["address"].downcase.include?("paris")
          hashed_property = {}
          hashed_property[:link] = "https://liberkeys.com/portails/" + item["slug"]
          hashed_property[:surface] = item["surface"].to_i
          hashed_property[:area] = perform_district_regex(item["address"])
          hashed_property[:rooms_number] = item["room_count"]
          hashed_property[:price] = item["price"].to_i
          if go_to_prop?(hashed_property, 7)
            property = fetch_json_get("https://api.liberkeys.com/portal/properties/#{item["slug"]}")
            hashed_property[:description] = property["description"]
            hashed_property[:bedrooms_number] = item["bedroom_count"]
            hashed_property[:flat_type] = get_type_flat(item["type"])
            hashed_property[:agency_name] = @source
            hashed_property[:floor] = regex_gen(property["floor"], '(\d)(\s)sur').to_int_scrp
            hashed_property[:has_elevator] = nil
            property["building_services"].each do |service|
              service == "Ascenseur" ? hashed_property[:has_elevator] = true : nil
            end
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = property["agent"]["phone"]
            hashed_property[:images] = item["low_quality_media"].each { |img| img.gsub!("//s3-eu-west-3", "https://s3-eu-west-3") }
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
