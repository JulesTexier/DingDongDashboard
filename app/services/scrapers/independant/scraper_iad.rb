class Independant::ScraperIad < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Iad"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_text(item, ".button__highlight") == "Sous compromis"
          hashed_property = {}
          hashed_property[:link] = "https://www.iadfrance.fr" + access_xml_link(item, ".c-offer__title", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".c-offer__title").strip, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".c-offer__localization"))
          hashed_property[:description] = access_xml_text(item, ".c-offer__description").strip
          hashed_property[:rooms_number] = access_xml_text(item, ".c-offer__footer.row > div:nth-child(2)").strip.to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, ".c-offer__price").strip, '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, ".offer__description > p").strip
            hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, ".offer__information-2").strip.gsub(" ", "").gsub(/[^[:print:]]/, ""), 'chambre(s?)(\d)*').to_int_scrp
            hashed_property[:bedrooms_number] == 0 ? hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp : nil
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, ".h1").strip)
            hashed_property[:agency_name] = @source
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".offer__slider-item > img", "src")
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
