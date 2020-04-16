class Independant::ScraperLaMaisonImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.lamaisonimmo.fr/catalog/advanced_search_result.php?action=update_search&search_id=1663963762147810&map_polygone=&C_28=Vente&C_28_search=EGAL&C_28_type=UNIQUE&C_27_REPLACE=1&C_27_search=EGAL&C_27_type=UNIQUE&C_27=1&C_65_REPLACE=75002+paris%2C+75009+paris%2C+75015+paris%2C+75001+paris%2C+75003+paris%2C+75009+paris%2C+75005+paris%2C+75006+paris%2C+75007+paris%2C+75008+paris%2C+75004+paris%2C+75010+paris%2C+75011+paris%2C+75012+paris%2C+75014+paris%2C+75016+paris%2C+75017+paris%2C+75018+paris%2C+75019+paris%2C+75020+paris&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75002+paris%2C+75009+paris%2C+75015+paris%2C+75001+paris%2C+75003+paris%2C+75004+paris%2C+75009+paris%2C+75005+paris%2C+75006+paris%2C+75007+paris%2C+75008+paris%2C+75010+paris%2C+75011+paris%2C+75012+paris%2C+75014+paris%2C+75016+paris%2C+75017+paris%2C+75018+paris%2C+75019+paris%2C+75020+paris&C_30_MIN=&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MAX=&C_33_search=COMPRIS&C_33_type=NUMBER&C_33_MAX=&C_33_MIN=0&C_38_search=COMPRIS&C_38_type=NUMBER&C_38_MAX=&C_38_MIN=0&C_36_search=COMPRIS&C_36_type=NUMBER&C_36_MAX=&C_36_MIN="
    @source = "La Maison Immo"
    @main_page_cls = "div.bien"
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
        hashed_property[:link] = "https://www.lamaisonimmo.fr" + access_xml_link(item, "a:nth-child(1)", "href")[0].to_s.gsub("..", "")
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "a:nth-child(1) > h3"))
        access_xml_text(item, "span.listing_price").include?("dont") ? hashed_property[:price] = regex_gen(access_xml_text(item, "span.listing_price").gsub(" ", ""), '(\d)*(.)*(dont)').to_int_scrp : hashed_property[:price] = access_xml_text(item, "span.listing_price").to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".listing_criteres"), '(\d+)(\s)Pi').to_int_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".listing_criteres"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, ".description").strip
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, ".listing_criteres").gsub(" ", ""), '(,)(\d*)(Ch)').to_int_scrp if access_xml_text(item, ".listing_criteres").gsub(" ", "").match(/(,)(\d*)(Ch)/i).is_a?(MatchData)
          hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          images = access_xml_link(html, "div.img", "style")
          images.each do |image_url|
            hashed_property[:images].push("https://www.lamaisonimmo.fr" + regex_gen(image_url.gsub!("background:url('..", ""), "(.)*(.jpg)"))
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
