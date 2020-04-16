class Independant::ScraperGerando < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.gerandoimmobilier.fr/catalog/advanced_search_result.php?action=update_search&search_id=1664115282882257&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_65_search=CONTIENT&C_65_type=TEXT&C_65=PARIS&C_27=&C_27_search=EGAL&C_27_type=UNIQUE&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&C_30_MAX=&C_38_search=COMPRIS&C_38_type=NUMBER&C_38_MIN=&C_34_search=COMPRIS&C_34_type=NUMBER&C_34_MIN=&page=1&search_id=1664115282882257&sort=0"
    @source = "Gérando Immobilier"
    @main_page_cls = "section.unBien"
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
        next if get_type_flat(access_xml_link(item, "h2 > a", "href")[0]) == "Parking"
        hashed_property = {}
        hashed_property[:link] = "http://www.gerandoimmobilier.fr/" + access_xml_link(item, "h2 > a", "href")[0].gsub("../", "")
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.caract"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.caract").remove_acc_scrp, '(\d+)(.?)(piece\(s\))').to_int_scrp
        hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "div.caract"), '(\d+)(.?)(chambre\(s\))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div > div:nth-child(2) > div > h3 > div > div > span").split("dont")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = perform_district_regex(access_xml_text(html, "ul.list-group"))
          hashed_property[:description] = access_xml_text(html, "p.description").tr("\n\t\r", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33142815500"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "img.img-responsive", "src").select { |img| !img.include?("../externalisation/gli") }
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
