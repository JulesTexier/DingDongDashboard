class Group::ScraperStephanePlaza < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Stephane Plaza"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      json = fetch_main_page(args)
      json["results"].each do |property|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.stephaneplazaimmobilier.com/immobilier-acheter/" + property["id"].to_s + "/" + property["slug"].to_s + "?token=" + json["token"]
          hashed_property[:surface] = regex_gen(property["properties"]["surface"], '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(property["properties"]["codePostal"], args.zone)
          hashed_property[:area] = perform_district_regex(property["properties"]["city"], args.zone) if hashed_property[:area] == 'N/C' && args.zone != "Paris (75)"
          hashed_property[:rooms_number] = property["properties"]["room"]
          hashed_property[:price] = property["price"].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            hashed_property[:bedrooms_number] = property["properties"]["bedroom"]
            hashed_property[:description] = property["description"]
            if property["type"] == "1"
              hashed_property[:flat_type] = "Appartement"
            elsif property["type"] == "2"
              hashed_property[:flat_type] = "Maison"
            else
              hashed_property[:flat_type] = "N/C"
            end
            hashed_property[:agency_name] = @source
            hashed_property[:floor] = property["properties"]["floor"]
            hashed_property[:has_elevator] = property["properties"]["lift"]
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = property["thumbnails"]
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
