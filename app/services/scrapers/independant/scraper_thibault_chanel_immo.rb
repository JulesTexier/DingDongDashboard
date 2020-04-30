class Independant::ScraperThibaultChanelImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.thibaultchanel.com/search-property-result/?location=&category=&bedrooms=&bathrooms=&min_price=0&max_price=10000000&min_area=0&max_area=1000"
    @source = "Thibault Chanel Immobilier"
    @main_page_cls = "article"
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
        status = access_xml_text(item, ".property-label")
        next if (status.include?("SOUS PROMESSE") || status.include?("VENDU"))
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "div:nth-child(1) > a:nth-child(1)", "href")[0].to_s
        title = access_xml_text(item, ".property-title").strip.gsub(/[^[:print:]]/, "")
        hashed_property[:area] = perform_district_regex(title)
        hashed_property[:price] = access_xml_text(item, ".property-price > span").split("€")[0].to_int_scrp
        hashed_property[:surface] = regex_gen(title, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.property-content > div:nth-child(1) > div:nth-child(2) > div:nth-child(1)").strip
          hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          raw_elevator = access_xml_text(html, ".value-_noo_property_field_ascenseur")
          if !raw_elevator.empty? && !hashed_property[:has_elevator].nil?
            hashed_property[:has_elevator] = true if raw_elevator == "Oui"
            hashed_property[:has_elevator] = false if raw_elevator == "Non"
          end
          hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "div.detail-field.row").remove_acc_scrp, '(piece(s?))(\d)').to_int_scrp
          raw_floor = access_xml_text(html, ".value-_noo_property_field_etage")
          hashed_property[:floor] = raw_floor.to_int_scrp if !raw_floor.nil?
          raw_metro = access_xml_text(html, ".value-_noo_property_field_metro")
          raw_metro.nil? ? hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description]) : hashed_property[:subway_ids] = perform_subway_regex(raw_metro)
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".noo-lightbox-item", "href")
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
