class Independant::ScraperHosman < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Hosman"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |property|
        begin
          hashed_property = {}
          hashed_property[:link] = property["property_show_url"]
          hashed_property[:surface] = property["area"].to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(property["zip_code"])
          hashed_property[:rooms_number] = property["room_number"]
          hashed_property[:price] = property["sale"]["price"]
          hashed_property[:floor] = property["floor"]
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.container:nth-child(2)").strip.gsub("l\'oeil de l'expert", "").gsub(/[^[:print:]]/, "").gsub('\n', "")
            hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
            hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:agency_name] = @source
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = property["property_pictures"]
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
