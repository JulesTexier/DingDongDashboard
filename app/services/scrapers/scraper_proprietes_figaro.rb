class ScraperProprietesFigaro < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "https://proprietes.lefigaro.fr/annonces/immobilier-paris-ile+de+france-france/?tri=2"
      @source = "Propr. Figaro"
      @main_page_cls = "div.item-container-inline"
      @type = "Static"
      @waiting_cls = "properties-grid"
      @multi_page = false
      @properties = []
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://proprietes.lefigaro.fr" + access_xml_link(item, "h2.h2-like > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.itemlist-infos > ul > li:nth-child(1) > span.nb"), '(\d+(.?)(\d*))').to_float_to_int_scrp
          hashed_property[:area] = access_xml_text(item, "span.itemlist-localisation > span").area_translator_scrp
        #   hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(item, "ul.itemlist-caracteristiques"), '(\d+(.?)(?=chambres))').to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.itemlist-infos > ul > li:nth-child(2) > span.nb"), '(\d+(.?)(\d*))').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "span.itemlist-price-nb").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "span.itemlist-title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if is_property_clean(hashed_property)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#js-description").specific_trim_scrp("\n").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.owl-lazy", "data-src")
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
  