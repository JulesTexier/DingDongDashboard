class Hub::ScraperBienIci < Scraper
  attr_accessor :source, :params, :properties

  def initialize
    @source = "BienIci"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args)["realEstateAds"].each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.bienici.com/annonce/vente/" + item["id"]
          hashed_property[:surface] = item["surfaceArea"].round if item["surfaceArea"].is_a?(Integer) ## the json is sometimes an array for bad properties
          hashed_property[:area] = perform_district_regex(item["postalCode"], args.zone)
          hashed_property[:rooms_number] = item["roomsQuantity"]
          hashed_property[:price] = item["price"] if item["price"].is_a?(Integer)
          hashed_property[:is_new_construction] = item["newProperty"]
          next if hashed_property[:link].match(/(visiteonline-)/i).is_a?(MatchData)
          next if hashed_property[:surface].nil? || hashed_property[:price].nil?
          if go_to_prop?(hashed_property, 7)
            hashed_property[:bedrooms_number] = item["bedroomsQuantity"]
            hashed_property[:description] = item["description"]
            hashed_property[:flat_type] = item["propertyType"]
            hashed_property[:floor] = item["floorQuantity"]
            hashed_property[:has_elevator] = item["hasElevator"]
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            item["photos"].each { |img_hash| hashed_property[:images].push(img_hash["url_photo"]) }
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
