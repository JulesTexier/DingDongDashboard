class ScraperGuyHoquet < Scraper
    attr_accessor :url, :properties, :source, :xml_first_page
  
    def initialize
      @url = "https://www.guy-hoquet.com/biens/result#1&p=1&t=3&f10=1&f20=75_c2&f30=appartement,maison"
      @source = "Guy Hoquet"
      @xml_first_page = "#properties-container > div > div.section-content.section-slick  > div"
    end
  
    def extract_first_page
      xml = fetch_main_page(@url, @xml_first_page, "Dynamic", "resultat-item")
      hashed_properties = []
      puts xml.count
      xml.each do |item|
        begin
          hashed_property = {}
  
          hashed_property[:link] = access_xml_link(item, "a.property_link_block", "href")[0].to_s
          hashed_property[:rooms_number] = access_xml_text(item, "div.actions > span:nth-child(1)").to_float_to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.actions > span:nth-child(2)"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.price"), '(\d)(.*)(€)').to_int_scrp

          hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
        rescue StandardError => e
          puts e.message
          puts e.backtrace
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
      # puts hashed_properties.to_json
      puts JSON.pretty_generate(hashed_properties)
      enrich_then_insert(hashed_properties)
    end
  
    private
  
    def extract_each_flat(prop)
      flat_data = {}
      html = fetch_static_page(prop[:link])
      flat_data[:link] = prop[:link]
      flat_data[:surface] = prop[:surface]
      flat_data[:area] = regex_gen(html.text, '(75)$*\d+{3}')
      flat_data[:price] = prop[:price]
      flat_data[:description] = access_xml_text(html, "span.description-more").strip
      flat_data[:bedrooms_number] = regex_gen(flat_data[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp
      flat_data[:flat_type] = get_type_flat(access_xml_text(html, "h1"))
      flat_data[:agency_name] = "Guy Hoquet"
      flat_data[:floor] = perform_floor_regex(flat_data[:description])
      flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
      flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
      flat_data[:provider] = "Agence"
      flat_data[:source] = @source
      flat_data[:images] = access_xml_link(html, ".de-biens-slider-itm", "href")
      return flat_data
    end
  end
  