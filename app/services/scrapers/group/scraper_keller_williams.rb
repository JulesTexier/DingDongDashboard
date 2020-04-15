class Group::ScraperKellerWilliams < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.kwfrance.com/catalog/advanced_search_result.php?action=update_search&search_id=&map_polygone=&C_28=Vente&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_65_temp=75&C_28_search=EGAL&C_28_type=UNIQUE&cfamille_id_search=CONTIENT&cfamille_id_type=TEXT&cfamille_id=1%2C2&cfamille_id_tmp=1&cfamille_id_tmp=2&C_34_search=COMPRIS&C_34_type=NUMBER&C_34_MIN=&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&C_30_MAX=&C_30=0"
    @source = "Keller Williams"
    @main_page_cls = "a.element-item"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @wait = 0
    @page_nbr = 0
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.kwfrance.com/" + item["href"].gsub("../", "")
        hashed_property[:surface] = access_xml_text(item, "span.number").split(" ")[0].to_float_to_int_scrp
        hashed_property[:price] = access_xml_text(item, "span.prix").split("\u0080")[0].to_int_scrp
        hashed_property[:rooms_number] = access_xml_text(item, "span.number").split(" ")[1].to_int_scrp
        hashed_property[:bedrooms_number] = access_xml_text(item, "span.number").split(" ")[2].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = perform_district_regex(access_xml_array_to_text(html, "#accordion"))
          hashed_property[:description] = access_xml_text(html, "p.description").strip
          hashed_property[:flat_type] = regex_gen(access_xml_array_to_text(html, "#accordion"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison|(DEMEURE DE PRESTIGE))")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "a.link_img_bien", "href").map { |img| "https://www.kwfrance.com/" + img.gsub!("../", "") }
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        puts e.message
        next
      end
    end
    return @properties
  end
end
