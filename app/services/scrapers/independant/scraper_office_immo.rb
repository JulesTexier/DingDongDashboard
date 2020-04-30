class Independant::ScraperOfficeImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://office-immo.com/resultat-recherche/?type=|Appartement|Maison|Loft&nature=|1&surface=&budget=&localisation=|75&nbPiece="
    @source = "Office Immo"
    @main_page_cls = "div.off-home"
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
        hashed_property[:link] = "http://office-immo.com" + access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "a:nth-child(1) > div:nth-child(2) > div:nth-child(1) > span:nth-child(1)"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "a:nth-child(1) > div:nth-child(1) > div:nth-child(1) > span:nth-child(2)"))
        hashed_property[:price] = access_xml_text(item, "a:nth-child(1) > div:nth-child(1) > div:nth-child(1) > span:nth-child(3)").strip.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          if access_xml_text(html, "div.col-4").downcase.include?("studio")
            hashed_property[:rooms_number] = 1
            hashed_property[:flat_type] = "Studio"
          else
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h3"))
            hashed_property[:rooms_number] = access_xml_text(html, "div.col-4:nth-child(2) > p:nth-child(2) > span:nth-child(1)").to_int_scrp
            hashed_property[:bedrooms_number] = access_xml_text(html, "div.col-4:nth-child(3) > p:nth-child(2) > span:nth-child(1)").to_int_scrp
          end
          hashed_property[:description] = access_xml_text(html, "div.row:nth-child(5) > div:nth-child(1) > p:nth-child(2)").strip
          hashed_property[:floor] = access_xml_text(item, "a:nth-child(1) > div:nth-child(2) > div:nth-child(1) > span:nth-child(2)").to_float_to_int_scrp
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(item, "a:nth-child(1) > div:nth-child(2) > div:nth-child(1) > span:nth-child(3)"))
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = @source
          hashed_property[:contact_number] = access_xml_text(html, ".info-agent > div:nth-child(2) > a:nth-child(2)").gsub(" ", "").gsub(".", "").convert_phone_nbr_scrp
          hashed_property[:images] = access_xml_link(html, "a.fancy-carousel", "href")
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
