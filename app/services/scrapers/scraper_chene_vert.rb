class ScraperCheneVert < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "http://www.le-chene-vert.com/annonces-liste.asp?typeliste=&tri=nouveaute"
      @source = "Chene Vert"
      @main_page_cls = "#grid-container > ul > li"
      @type = "Static"
      @waiting_cls = nil
      @multi_page = false
      @wait = 0
      @page_nbr = 1
      @properties = []
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.le-chene-vert.com/" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:price] =  regex_gen(access_xml_text(item, "div.cbp-l-caption-body > div.btn-u"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.cbp-l-caption-body"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:rooms_number] == 0 && hashed_property[:rooms_number] = 1  
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.cbp-l-caption-body"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:surface] = regex_gen(access_xml_text(html, "h4"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
            hashed_property[:description] = access_xml_text(html, "div.tag-box > p").strip
            hashed_property[:flat_type] = regex_gen(hashed_property[:description], "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:agency_name] = "Chene Vert"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "span.overlay-zoom > img", "src")
              @properties.push(hashed_property) ##testing purpose
              enrich_then_insert_v2(hashed_property)
              i += 1
              break if i == limit
          end
        puts JSON.pretty_generate(hashed_property)
        rescue StandardError => e
          error_outputs(e, @source)
          next
        end
      end
      return @properties
    end
  end
  