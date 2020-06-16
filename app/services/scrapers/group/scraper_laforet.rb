class Group::ScraperLaforet < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Laforet"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args)["data"].each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.laforet.com/agence-immobiliere/paris11bastille/acheter/paris/" + item["slug"]
          hashed_property[:area] = perform_district_regex(item["address"]["postcode"], args.zone)
          hashed_property[:surface] = item["surface"].to_i
          hashed_property[:rooms_number] = item["rooms"]
          hashed_property[:price] = item["price"].to_i
          if go_to_prop?(hashed_property, 7)
            property = fetch_json_get(item["links"]["self"])
            hashed_property[:bedrooms_number] = item["bedrooms"]
            hashed_property[:flat_type] = item["type_label"]
            hashed_property[:description] = property["description"]
            hashed_property[:floor] = property["floor"]
            hashed_property[:has_elevator] = property["has_lift"]
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description], args.zone)
            hashed_property[:provider] = "Agence"
            hashed_property[:agency_name] = property["agency"]["name"]
            hashed_property[:contact_number] = property["agency"]["address"]["phone"]
            hashed_property[:source] = @source
            hashed_property[:images] = item["photos"]
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
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
