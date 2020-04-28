class Independant::ScraperCapitaliParis < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "http://www.capitali-paris.com/catalog/advanced_search_result.php?action=update_search&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_REPLACE=1&C_27_search=EGAL&C_27_type=UNIQUE&C_27=1&C_65_REPLACE=Paris&C_65_search=CONTIENT&C_65_type=TEXT&C_65=Paris&C_34_search=SUPERIEUR&C_34_type=NUMBER&C_34_MIN=&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MAX=&C_30_MIN=0&search_id=1664043544559140&page=1&search_id=1664043544559140&sort=0"
    @source = "Capitali Paris"
    @main_page_cls = "article.bien"
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
        link_brut = access_xml_link(item, "div.row > div.col-sm-6 > a", "href")[0].to_s
        hashed_property[:link] = "http://www.capitali-paris.com" + link_brut[2..link_brut.length]
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".carac"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = access_xml_text(item, ".carac > div:nth-child(3)").to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".carac"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = perform_district_regex(access_xml_text(html, "ul.list-group:nth-child(2) > li.list-group-item:nth-child(1) > div").split("Code postal")[1])
          hashed_property[:description] = access_xml_text(html, ".description").gsub("\t", "").gsub("\n", "").strip
          hashed_property[:flat_type] = regex_gen(hashed_property[:description], "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:agency_name] = "Capitali Paris"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.img", "style").map { |img| "http://www.capitali-paris.com" + img.split("('..")[1].split("')")[0] }
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
