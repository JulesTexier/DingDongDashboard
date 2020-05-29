class Group::ScraperMorissImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "MorissImmobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          if access_xml_text(item, "div.ribbon-inside") == "Disponible"
            hashed_property = {}
            hashed_property[:link] = access_xml_link(item, "div.item > a", "href")[0].to_s
            hashed_property[:surface] = regex_gen(access_xml_text(item, "div.infosize_unit_type4 > span"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
            hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.property_address_type4 > span > a"))
            next if hashed_property[:area] == "N/C"
            hashed_property[:rooms_number] = access_xml_text(item, "div.inforoom_unit_type4 > span").to_int_scrp
            hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
            hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h4 > a"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            if go_to_prop?(hashed_property, 7)
              html = fetch_static_page(hashed_property[:link])
              hashed_property[:description] = access_xml_text(html, "div.wpestate_property_description > p").specific_trim_scrp("\n").strip
              hashed_property[:agency_name] = access_xml_text(html, "div.agent_unit > div > h4 > a")
              hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
              hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
              hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
              hashed_property[:provider] = "Agence"
              hashed_property[:source] = @source
              hashed_property[:images] = access_xml_link(html, "div.gallery_wrapper > div", "style")
              hashed_property[:images].each do |image_url|
                image_url.gsub!("background-image:url(", "").gsub!(")", "")
              end
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
    end
    return @properties
  end
end
