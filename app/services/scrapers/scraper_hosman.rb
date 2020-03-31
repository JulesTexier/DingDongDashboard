class ScraperHosman < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.hosman.co/api/v1/properties?zones=[%22Paris,%20France%22]&min_area=&max_budget=&min_room_number=0&display_sold=false"
    @source = "Hosman"
    @main_page_cls = ""
    @type = ""
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_json(self).each do |property|
      begin
        hashed_property = {}
        hashed_property[:link] = property["property_show_url"]
        hashed_property[:surface] = property["area"].to_float_to_int_scrp
        hashed_property[:area] = property["zip_code"]
        hashed_property[:rooms_number] = property["room_number"]
        hashed_property[:price] = property["sale"]["price"]
        hashed_property[:floor] = property["floor"]
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.container:nth-child(2)").strip.gsub("l\'oeil de l'expert", "").gsub(/[^[:print:]]/, "").gsub('\n', "")
          hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
          hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:agency_name] = @source
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = property["property_pictures"]
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
