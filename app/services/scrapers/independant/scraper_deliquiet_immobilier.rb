class Independant::ScraperDeliquietImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.deliquiet-immobilier.com/catalog/advanced_search_result.php?action=update_search&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_search=EGAL&C_27_type=UNIQUE&C_27=&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75001%20PARIS%2C75002%20PARIS%2C75003%20PARIS%2C75004%20PARIS%2C75005%20PARIS%2C75006%20PARIS%2C75007%20PARIS%2C75008%20PARIS%2C75009%20PARIS%2C75010%20PARIS%2C75011%20PARIS%2C75012%20PARIS%2C75013%20PARIS%2C75014%20PARIS%2C75015%20PARIS%2C75016%20PARIS%2C75017%20PARIS%2C75018%20PARIS%2C75019%20PARIS%2C75020%20PARIS%2C&C_30_search=COMPRIS&C_30_type=NUMBER&C_30_MAX=&C_30_MIN=0&C_33_search=COMPRIS&C_33_type=NUMBER&C_33_MIN=&page=1&search_id=1662214799533655&sort=0"
    @source = "Deliquiet Immobilier"
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
        if !access_xml_text(item, ".picto").empty?
          next if access_xml_text(item, ".picto").downcase.remove_acc_scrp == ("compromis signe" || "offre achat acceptee")
        end
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, ".titreBien", "href")[0].to_s.gsub("../", "http://www.deliquiet-immobilier.com/")
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
          raw_images = html.css("#diapoDetail .img")
          hashed_property[:images] = []
          raw_images.each { |x| hashed_property[:images].push(regex_gen(x.attributes["style"].value, '(url)\((.)*\)').gsub("url('..", "http://www.deliquiet-immobilier.com").gsub("')", "")) }
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
