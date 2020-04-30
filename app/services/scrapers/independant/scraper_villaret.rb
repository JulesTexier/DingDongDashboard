class Independant::ScraperVillaret < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.villaret-immobilier.com/catalog/advanced_search_result.php?action=update_search&search_id=&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75003+paris%2C75004+paris%2C75005+paris%2C75006+paris%2C75008+paris%2C75009+paris%2C75010+paris%2C75011+paris%2C75012+paris%2C75015+paris%2C75016+paris&C_65_tmp=75003+paris&C_65_tmp=75004+paris&C_65_tmp=75005+paris&C_65_tmp=75006+paris&C_65_tmp=75008+paris&C_65_tmp=75009+paris&C_65_tmp=75010+paris&C_65_tmp=75011+paris&C_65_tmp=75012+paris&C_65_tmp=75015+paris&C_65_tmp=75016+paris&C_27_search=EGAL&C_27_type=TEXT&C_27=1%2C2%2CLoft&C_27_tmp=1&C_27_tmp=2&C_27_tmp=Loft&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&C_30_MAX="
    @source = "Villaret"
    @main_page_cls = "div.cell-product"
    @scraper_type = "Static"
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
        hashed_property[:link] = "https://www.villaret-immobilier.com" + access_xml_link(item, "a.link-product", "href")[0].to_s[2..-1]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.product-criteres"), '(\d+)(.?)(m)').to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.product-city"))
        hashed_property[:rooms_number] = access_xml_text(item, "div.product-type").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.product-price").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.product-desc").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:contact_number] = "+33153447474"
          hashed_property[:images] = []
          access_xml_link(html, "#slider_product > div > a > img", "src").each do |img|
            hashed_property[:images].push("https://www.villaret-immobilier.com/" + img.gsub!("../", ""))
          end
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
