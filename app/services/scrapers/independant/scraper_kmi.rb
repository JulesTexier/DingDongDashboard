class Independant::ScraperKmi < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "KMI"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_text(item, "div.ribbon-inside") == "VENDU" || access_xml_text(item, "div.listing_unit_price_wrapper") == "Nous consulter"
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.unit_details_x", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "span.infosize"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.property_location_image"))
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if hashed_property[:rooms_number] == 0
            if regex_gen(access_xml_text(item, "h4 > a"), "(studio)") == "studio" || regex_gen(access_xml_text(item, "h4 > a"), "(studette)") == "studette"
              hashed_property[:rooms_number] = 1
            else
              hashed_property[:rooms_number] = access_xml_text(item, "div.property_listing_details > span.inforoom").to_int_scrp + 1
            end
          end
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div#description").tr("\n\t", "").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "div.property_categs"))
            hashed_property[:agency_name] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > h4 > a").tr("\n\r\t", "")
            hashed_property[:contact_number] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > div:nth-child(3)").convert_phone_nbr_scrp
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.multi_image_slider_image", "style")
            hashed_property[:images].each do |img|
              img.gsub!("background-image:url(", "").chop!
            end
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
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
