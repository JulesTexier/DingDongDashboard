class Independant::ScraperBonjourOscar < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args
  
    def initialize
      @url = "https://www.bonjour-oscar.com/acheter/"
      @source = "Bonjour Oscar"
      @main_page_cls = "li.listGoods-item"
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
          hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.listGoods-zip"))
          hashed_property[:price] = regex_gen(access_xml_text(item, "span.listGoods-price"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.listGoods-infoBarRight > span:nth-child(1)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:surface] = 30
          if go_to_prop?(hashed_property, 7)     
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:surface] = access_xml_text(html, "span.spaces-value").to_float_to_int_scrp
        #     hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        #     hashed_property[:rooms_number] == 1 ? hashed_property[:bedrooms_number] = 1 : hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, "#infos > p:nth-child(7) > span.valueInfos"), '(\d+)').to_int_scrp
        #     hashed_property[:description] = access_xml_text(html, "article.col-md-6 > p").strip
        #     hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        #     hashed_property[:agency_name] = "Les Parisiennes"
        #     hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
        #     hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
        #     hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
        #     hashed_property[:provider] = "Agence"
        #     hashed_property[:source] = @source
        #     hashed_property[:images] = access_xml_link(html, "ul > li > img", "src")
        #     hashed_property[:images].collect! { |img| "https:" + img }
            #   @properties.push(hashed_property) ##testing purpose
            #   enrich_then_insert_v2(hashed_property)
            #   i += 1
            #   break if i == limit
        # byebug
          end
        #   byebug
        rescue StandardError => e
            error_outputs(e, @source)
          next
        end
        puts JSON.pretty_generate(hashed_property)
      end
    #   byebug
      return @properties
    end
  end
  