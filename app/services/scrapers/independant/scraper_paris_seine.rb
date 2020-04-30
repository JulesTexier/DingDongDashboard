class Independant::ScraperParisSeine < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.paris-seine-immobilier.com/catalog/advanced_search_result.php?action=update_search&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_REPLACE=1&C_27_search=EGAL&C_27_type=UNIQUE&C_27=2%2C1&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_65_temp=75&page=1&search_id=1663417493034890&sort=0"
    @source = "Paris Seine"
    @main_page_cls = "article.bien"
    @scraper_type = "Static"
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
        next if access_xml_text(item, "div.picto.text-uppercase") == "Vendu par l'agence"
        hashed_property = {}
        hashed_property[:link] = "https://www.paris-seine-immobilier.com/" + access_xml_link(item, "a.titreBien", "href")[0].gsub("../", "")
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.carac"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.code_postal"))
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.carac").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
        hashed_property[:price] = access_xml_array_to_text(item, "div.carac > div:nth-child(3)").split("\u0080")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.description").tr("\n\t\r", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33145446600"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          access_xml_raw(html, "div#diapoDetail").each do |imgs|
            access_xml_link(imgs, "div.img", "style").each do |img|
              hashed_property[:images].push("https://www.paris-seine-immobilier.com/" + img.split("../")[1].split("')")[0])
            end
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
