class Group::ScraperLadresse < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.ladresse.com/catalog/advanced_search_result.php?action=update_search&C_28=Vente&C_28_search=EGAL&C_28_type=UNIQUE&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_65_temp=75&C_27_search=EGAL&C_27_type=TEXT&C_27=&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&C_30_MAX=&30_MIN=&30_MAX="
    @source = "L'Adresse"
    @main_page_cls = "#listing_bien > div.row > div.col-lg-6"
    @scraper_type = "Static"
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
        hashed_property[:link] = "https://www.ladresse.com" + access_xml_link(item, "div.products-img > a", "href")[0].tr("..", "").to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "ul.products-infos-pictos"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.products-name"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        price_element = access_xml_text(item, "div.products-price")
        hashed_property[:price] = regex_gen(price_element, '(\d+)(.?)(\d+)(...)dont').tr("^0-9", "") != "" ? regex_gen(price_element, '(\d+)(.?)(\d+)(...)dont').tr("^0-9", "").to_float_to_int_scrp : price_element.tr("^0-9", "").to_float_to_int_scrp
        picto_element = access_xml_link(item, "ul.products-infos-pictos > li:nth(2) > img", "src").to_s
        if picto_element["picto-bed"] # if picto is a bedroom
          hashed_property[:rooms_number] = access_xml_text(item, "ul.products-infos-pictos > li:nth-child(2)").to_int_scrp + 1
          hashed_property[:bedrooms_number] = access_xml_text(item, "ul.products-infos-pictos > li:nth-child(2)").to_int_scrp
        elsif hashed_property[:flat_type] == "studio" || hashed_property[:flat_type] == "Studio"
          hashed_property[:rooms_number] = 1
          hashed_property[:bedrooms_number] = 1
        else
          hashed_property[:rooms_number] = nil
        end
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = access_xml_text(html, "ul.list-criteres > li:nth-child(1) > span").to_int_scrp
          hashed_property[:description] = access_xml_text(html, "div.content-desc").tr("\n\t", "").strip
          agency_area = perform_district_regex(access_xml_text(html, "div.agence-title"))
          desc_area = perform_district_regex(hashed_property[:description])
          desc_area != agency_area && desc_area != "N/C" ? hashed_property[:area] = desc_area : hashed_property[:area] = agency_area
          hashed_property[:floor] = regex_gen(access_xml_text(html, "ul.list-criteres > li:last-child > span"), '(\d+)/').to_int_scrp
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "ul.slides > li > a > img", "src")
          hashed_property[:images].collect! { |img| "https://www.ladresse.com" + img.gsub("..", "") }
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
