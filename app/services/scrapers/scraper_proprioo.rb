class ScraperProprioo < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "https://www.proprioo.fr/nosannonces?localisation=Paris&page=[[PAGE_NUMBER]]"
      @source = "Proprioo"
      @main_page_cls = "div.sc-1y2l6jx-0"
      @type = "Static"
      @waiting_cls = nil
      @multi_page = true
      @wait = 1
      @page_nbr = 1
      @properties = []
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          link2 = "https://www.proprioo.fr" + access_xml_link(item, ":nth-child(2)", "href")[0].to_s
          link3 = "https://www.proprioo.fr" + access_xml_link(item, ":nth-child(3)", "href")[0].to_s
            if !link3.include?("annonce/") then hashed_property[:link] = link2
            else hashed_property[:link] = link3
            end
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.sc-1y2l6jx-4.eOcJRN > span:nth-child(2)"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "h4"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.sc-1y2l6jx-4.eOcJRN > span:nth-child(1)"), '(\d+)(.?)(P)').to_float_to_int_scrp

          if is_property_clean(hashed_property)
            html = fetch_dynamic_page(hashed_property[:link], "sc-1ew6aid-5", @wait)
            hashed_property[:area] = access_xml_text(html, "span.yBPec").area_translator_scrp
     
            hashed_property[:description] = access_xml_text(html, "div.j6vkol-0").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(html, "h1"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:agency_name] = "Proprioo"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img", "src")
            hashed_property[:images].delete_if { |img| img.include?("facebook") || img.include?("data:")}
              @properties.push(hashed_property) ##testing purpose
              enrich_then_insert_v2(hashed_property)
              i += 1
              break if i == limit
           end
        puts JSON.pretty_generate(hashed_property)
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          puts e.message
          puts e.backtrace
          next
        end
      end
      return @properties
    end
  end
  