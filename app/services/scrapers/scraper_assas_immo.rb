class ScraperAssasImmo < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "https://www.assasimmobilier.com/vente-loft-hotel-particulier-appartement-paris-assas-immobilier/"
      @source = "Assas Immo"
      @main_page_cls = "div.annonce_listing"
      @type = "Static"
      @waiting_cls = nil
      @multi_page = false
      @page_nbr = 1
      @properties = []
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.assasimmobilier.com/" + access_xml_link(item, "div.annonces_listing_container > div:nth-child(1) > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.value-prix > span > span"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if is_property_clean(hashed_property)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = regex_gen(access_xml_text(html, "#infos > p:nth-child(1) > span.valueInfos"), '(\d+)').to_s
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
            hashed_property[:rooms_number] == 1 ? hashed_property[:bedrooms_number] = 1 : hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, "#infos > p:nth-child(7) > span.valueInfos"), '(\d+)').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "article.col-md-6 > p").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:agency_name] = "Les Parisiennes"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul > li > img", "src")
            hashed_property[:images].collect! { |img| "https:" + img }
            if hashed_property[:area][0..1] == "75"
              @properties.push(hashed_property) ##testing purpose
              enrich_then_insert_v2(hashed_property)
              i += 1
              break if i == limit
            end
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
  