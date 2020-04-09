class ScraperEmileGarcin < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.emilegarcin.fr/catalog/advanced_search_result.php?action=update_search&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_65_REPLACE=%2CParis&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_64_search=INFERIEUR&C_64_type=TEXT&C_64=&cfamille_id=1%2C2&cfamille_id_tmp=1&cfamille_id_tmp=2&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MIN=&30_MIN=&C_30_MAX=&30_MAX=&products_sort_id=0"
    @source = "Emile Garcin"
    @main_page_cls = "div.un-bien"
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
        hashed_property[:link] = "https://www.emilegarcin.fr/" + access_xml_link(item, "a", "href")[0].gsub("../", "")
        hashed_property[:surface] = regex_gen(access_xml_text(item, "p.info"), '(\d+)(.?)(m)').to_int_scrp
        hashed_property[:area] = perform_district_regex(hashed_property[:link])
        hashed_property[:area] = nil if hashed_property[:area] == "N/C"
        hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "p.info"), '(\d+)(.?)(chambre(s?))').to_int_scrp
        rooms_number = regex_gen(access_xml_text(item, "p.type"), '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        rooms_number = hashed_property[:bedrooms_number] + 1 if rooms_number == 0
        hashed_property[:rooms_number] = rooms_number
        hashed_property[:price] = access_xml_text(item, "p.price").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = perform_district_regex(access_xml_text(html, "h1.title")) if hashed_property[:area].nil?
          hashed_property[:description] = access_xml_text(html, "div.description").strip.tr("\t\n", "")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:contact_number] = access_xml_text(html, "div.cont-phone").gsub(" ", "").tr("\t\n", "")
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          access_xml_link(html, "ul.slides > li > a", "href").each do |img|
            hashed_property[:images].push("https://www.emilegarcin.fr/" + img.gsub!("../", ""))
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
