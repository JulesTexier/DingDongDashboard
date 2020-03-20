class ScraperKmi < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.cabinet-kmi.com/recherche-avancee/page/[[PAGE_NUMBER]]?advanced_city=paris-2&chambres-min&surface-min&budget-max&submit=RECHERCHER&wpestate_regular_search_nonce=0cc36da597&_wp_http_referer=%2Facheter%2F"
    @source = "KMI"
    @main_page_cls = "div.property_listing"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = true
    @page_nbr = 6
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      unless access_xml_text(item, "div.ribbon-inside") == "VENDU" || access_xml_text(item, "div.listing_unit_price_wrapper") == "Nous consulter"
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.unit_details_x", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "span.infosize"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = regex_gen(access_xml_text(item, "div.property_location_image"), '(75)$*\d+{3}')
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if hashed_property[:rooms_number] == 0
            if regex_gen(access_xml_text(item, "h4 > a"), "(studio") == "studio" || regex_gen(access_xml_text(item, "h4 > a"), "(studette)") == "studette"
              hashed_property[:rooms_number] = 1
            else
              hashed_property[:rooms_number] = access_xml_text(item, "div.property_listing_details > span.inforoom").to_int_scrp + 1
            end
          end

          if is_property_clean(hashed_property)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div#description").tr("\n\t", "").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(html, "div.property_categs"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
            hashed_property[:agency_name] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > h4 > a").tr("\n\r\t", "")
            hashed_property[:contact_number] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > div:nth-child(3)").convert_phone_nbr_scrp
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.multi_image_slider_image", "style")
            hashed_property[:images].each do |img|
              img.gsub!("background-image:url(", "").chop!
            end
            @properties.push(hashed_property) ##testing purpose
            #enrich_then_insert_v2(hashed_property)
            i += 1
            break if i == limit
          end
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
    end
    return @properties
  end
end
