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
      @wait = 5
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.assasimmobilier.com" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(3)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "a > figure > figcaption > p:nth-child(2) > span"), '(\d+(.?)(\d*))(.)(€)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(2)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(1)"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:area] = regex_gen(hashed_property[:link], '(paris-(.)(\d+))').tr('^0-9', '')
          puts JSON.pretty_generate(hashed_property) 

        #   if is_property_clean(hashed_property)
            html = fetch_dynamic_page(hashed_property[:link], 'cycle', 5, nil)
            # hashed_property[:description] = access_xml_text(html, "p.descriptif").strip
            # hashed_property[:agency_name] = "Assas Immobilier"
            # hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            # hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            # hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            # hashed_property[:provider] = "Agence"
            # hashed_property[:source] = @source
            # hashed_property[:images] = access_xml_link(html, "img.autoScale", "src")
            # hashed_property[:images].collect! { |img| "https://www.assasimmobilier.com" + img }
            
            # data = []
            # html.css("div.cycle-pager img").each do |item|
            #     puts item
            # end
            

        #     if hashed_property[:area][0..1] == "75"
        #       @properties.push(hashed_property) ##testing purpose
        #       enrich_then_insert_v2(hashed_property)
        #       i += 1
        #       break if i == limit
        #     end
        #   end
          puts JSON.pretty_generate(hashed_property)
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
      return @properties
    end
  end
  