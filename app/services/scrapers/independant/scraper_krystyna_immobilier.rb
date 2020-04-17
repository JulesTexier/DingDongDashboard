class Independant::ScraperKrystynaImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.krystyna-immobilier.com/catalog/advanced_search_result.php?action=update_search&search_id=&map_polygone=&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_search=EGAL&C_27_type=TEXT&C_27=&C_34_MIN=&C_34_search=COMPRIS&C_34_type=NUMBER&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MAX=&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75013+PARIS&C_65_tmp=75013+PARIS&keywords=&C_33_MAX=&C_30_MIN="
    @source = "Krystyna"
    @main_page_cls = "div.product-listing"
    @type = "Static"
    @multi_page = false
    @page_nbr = 1
    @waiting_cls = nil
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.krystyna-immobilier.com" + access_xml_link(item, "> a", "href")[0].to_s.gsub("..", "")
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.products-name"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.products-localisation"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.products-name").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.products-price"), '(\d+)(.)(\d+)(.)(\d+)(...)(dont)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.products-name"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.product-description").specific_trim_scrp("\n").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.item-slider > a", "href")
          hashed_property[:images].collect! { |img| "https://www.krystyna-immobilier.com" + img.gsub("..", "") }
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
