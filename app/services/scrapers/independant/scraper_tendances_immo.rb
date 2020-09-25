class Independant::ScraperTendancesImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Tendances Immobilières"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          price = access_xml_text(item, ".price").gsub(/[^[:print:]]/, "")
          next if price.downcase.include?("vendu")
          hashed_property[:link] = access_xml_link(item, "a", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".area"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".location"))
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, ".body"))
          if hashed_property[:surface] < 25 || hashed_property[:flat_type] == "Studio"
            hashed_property[:rooms_number] = 1
            hashed_property[:bedrooms_number] = 0
          else
            hashed_property[:bedrooms_number] = access_xml_text(item, ".bedrooms").to_int_scrp
            hashed_property[:rooms_number] = hashed_property[:bedrooms_number] + 1
          end
          hashed_property[:price] = price.strip.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, ".property-detail > p").strip
            hashed_property[:subway_infos] = perform_subway_regex(access_xml_text(html, ".localisation"))
            hashed_property[:provider] = "Agence"
            hashed_property[:agency_name] = @source
            hashed_property[:contact_number] = "0155323232"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".gallery> img", "src")
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
