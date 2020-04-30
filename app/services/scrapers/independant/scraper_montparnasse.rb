class Independant::ScraperMontparnasse < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.montparnasseimmobilier.com/catalog/advanced_search_result.php?action=update_search&search_id=&map_polygone=&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_search=EGAL&C_27_type=TEXT&C_27=2%2C1&C_27_tmp=2&C_27_tmp=1&C_34_MIN=&C_34_search=COMPRIS&C_34_type=NUMBER&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MAX=&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75015+PARIS%2C75005+PARIS%2C75007+PARIS&C_65_tmp=75015+PARIS&C_65_tmp=75005+PARIS&C_65_tmp=75007+PARIS&keywords=&C_33_MAX=&C_30_MIN="
    @source = "Montparnasse Immobilier"
    @main_page_cls = "div.product-listing"
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
        hashed_property[:link] = "https://www.montparnasseimmobilier.com/" + access_xml_link(item, "a", "href")[1].gsub("../", "")
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.products-localisation"))
        hashed_property[:description] = access_xml_text(item, "div.products-description").specific_trim_scrp("\n").strip
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.products-description").remove_acc_scrp.specific_trim_scrp("\n"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp
        hashed_property[:surface] = nil if hashed_property[:surface] == 0
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.products-description").remove_acc_scrp.convert_written_number_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
        hashed_property[:rooms_number] = nil if hashed_property[:rooms_number] == 0
        hashed_property[:price] = access_xml_text(item, "div.products-price").split("dont")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "#box_slider_header_product > div > ul").remove_acc_scrp, '(\d+)(.?)(piece\(s\))').to_int_scrp if hashed_property[:rooms_number].nil?
          hashed_property[:surface] = regex_gen(access_xml_text(html, "#box_slider_header_product > div > ul"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp if hashed_property[:surface].nil?
          hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33142842121"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.item-slider > a", "href").map { |img| "https://www.montparnasseimmobilier.com/" + img.gsub("../", "") }
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
