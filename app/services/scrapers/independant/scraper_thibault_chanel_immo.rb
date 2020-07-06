class Independant::ScraperThibaultChanelImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Thibault Chanel Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
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
            hashed_property[:flat_type] = "N/C"
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
            hashed_property[:subway_infos] = perform_subway_regex(raw_metro) if !raw_metro.nil?
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".noo-lightbox-item", "href")
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
