class ScraperEnfantsRouges < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "https://www.agencedesenfantsrouges.com/fr/recherche/?nature=1&type[]=1&type[]=2&city[]=32552&city[]=32553&city[]=32569&city[]=32554&city[]=32560&city[]=32561&city[]=32562&city[]=32565&city[]=32567&city[]=32568&city[]=32559&price&age&tenant_min&tenant_max&rent_type&newprogram_delivery_at&newprogram_delivery_at_display&currency=EUR&customroute&homepage&order=news%7Cdesc"
      @source = "Enfants Rouges"
      @main_page_cls = "li.ad"
      @type = "Static"
      @waiting_cls = nil
      @multi_page = false
      @wait = 0
      @properties = []
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.agencedesenfantsrouges.com" + access_xml_link(item, "a.button", "href")[1].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "li.area"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "li.price > div"), '(\d)(.*)').to_int_scrp
          hashed_property[:area] = access_xml_text(item, "div.titles > h2").area_translator_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.titles > h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(html, "div.detailsList > div.details > ul"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
            hashed_property[:description] = access_xml_text(html, "p#description").strip
            hashed_property[:agency_name] = "Enfants Rouges"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.item > a > img", "src")
              @properties.push(hashed_property) ##testing purpose
              enrich_then_insert_v2(hashed_property)
              i += 1
              break if i == limit
          end
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
  