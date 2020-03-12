class ScraperKmi < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.cabinet-kmi.com/recherche-avancee/page/[[PAGE_NUMBER]]?advanced_city=paris-2&chambres-min&surface-min&budget-max&submit=RECHERCHER&wpestate_regular_search_nonce=0cc36da597&_wp_http_referer=%2Facheter%2F"
    @source = "KMI"
    @xml_first_page = "div.property_listing"
  end

  def extract_many_pages(page_extraction_nbr)
    xml = fetch_many_pages(url, page_extraction_nbr, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      unless access_xml_text(item, "div.ribbon-inside") == "VENDU" || access_xml_text(item, "div.listing_unit_price_wrapper") == "Nous consulter"
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.unit_details_x", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "span.infosize"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = regex_gen(access_xml_text(item, "div.property_location_image"), '(75)$*\d+{3}')
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if hashed_property[:rooms_number] == 0
            if regex_gen(access_xml_text(item, "h4 > a"), "(stud(io|ette))") == "studio" || regex_gen(access_xml_text(item, "h4 > a"), "(stud(io|ette))") == "studette"
              hashed_property[:rooms_number] = 1
            else
              hashed_property[:rooms_number] = access_xml_text(item, "div.property_listing_details > span.inforoom").to_int_scrp + 1
            end
          end
          hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
    end
    enrich_then_insert(hashed_properties)
  end

  private

  def extract_each_flat(prop)
    flat_data = {}
    html = fetch_static_page(prop[:link])
    flat_data[:link] = prop[:link]
    flat_data[:surface] = prop[:surface]
    flat_data[:area] = prop[:area]
    flat_data[:rooms_number] = prop[:rooms_number]
    flat_data[:price] = prop[:price]
    flat_data[:description] = access_xml_text(html, "div#description").tr("\n\t", "").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "div.property_categs"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
    flat_data[:agency_name] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > h4 > a").tr("\n\r\t", "")
    flat_data[:contact_number] = access_xml_text(html, "div.agent_unit > div:nth-child(2) > div:nth-child(3)").convert_phone_nbr_scrp
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "div.multi_image_slider_image", "style")
    flat_data[:images].each do |img|
      img.gsub!("background-image:url(", "").chop!
    end
    return flat_data
  end
end
