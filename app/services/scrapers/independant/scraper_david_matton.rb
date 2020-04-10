class Independant::ScraperDavidMatton < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_request, :http_type

  def initialize
    @url = "http://www.davidmattonimmobilier.com/catalog/advanced_search_result.php?action=update_search&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_REPLACE=1&C_27_search=EGAL&C_27_type=UNIQUE&C_27=2%2C1&C_65_REPLACE=Paris&C_65_search=CONTIENT&C_65_type=TEXT&C_65=Paris&page=1&search_id=1663595643973767&sort=PRODUCT_LIST_DATEd"
    @source = "David Matton"
    @main_page_cls = "article.bien"
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
        hashed_property[:link] = "http://www.davidmattonimmobilier.com/" + access_xml_link(item, ".titreBien", "href")[0].to_s.gsub("../", "")
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".carac"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(item.text)
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".carac"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        price_item = access_xml_text(item, ".carac > div:nth-child(3)")
        price_item.include?("dont") ? hashed_property[:price] = regex_gen(price_item, '(\d)(.*)(dont)').to_int_scrp : hashed_property[:price] = price_item.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          detail = access_xml_text(html, "#detailCarac")
          hashed_property[:description] = access_xml_text(html, ".description").strip
          hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp if regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp != 0
          hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.img", "style").map { |img| "http://www.davidmattonimmobilier.com" + img.split("url('")[1].split("')")[0][2..-1] }
          hashed_property[:images].delete("http://www.davidmattonimmobilier.com/office8/david_matton_immobilier/catalog/images/background.jpg")
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
