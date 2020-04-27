class Group::ScraperDanielFeau < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://danielfeau.com/fr/acheter/paris-neuilly-boulogne-saint-cloud"
    @source = "Daniel Feau"
    @main_page_cls = "li.property.initial"
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
        hashed_property[:link] = "https://danielfeau.com" + access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h3 > span"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2 > div:nth-child(1)"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h3 > span").remove_acc_scrp, '(\d+)(.?)(piece(s)?)').to_int_scrp
        hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "h3 > span").remove_acc_scrp, '(\d+)(.?)(chambre(s)?)').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
        hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h3 > span"))
        next if hashed_property[:area] == "N/C"
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.comment").tr("\r\n", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(html, "article.agency > div.info > h2 > a")
          hashed_property[:contact_number] = access_xml_text(html, "article.agency > div.info > p > span.phone").gsub("(0)", "")
          hashed_property[:images] = access_xml_link(html, "img.picture", "src").uniq
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
