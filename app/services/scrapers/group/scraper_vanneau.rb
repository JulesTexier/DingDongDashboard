class Group::ScraperVanneau < Scraper
  attr_accessor :source, :params, :properties

  def initialize
    @source = "Vanneau"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      json_item = fetch_main_page(args)
      access_xml_raw(Nokogiri::HTML.parse(json_item["html"]), "div.property__search-item").each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.vaneau.fr" + access_xml_link(item, "a.link__property.full-link", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "div.property-surface").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.property-name"))
          hashed_property[:bedrooms_number] = access_xml_text(item, "div.property-bedrooms").to_int_scrp
          hashed_property[:rooms_number] = hashed_property[:bedrooms_number] + 1 ##TO DO - CHANGE THIS LOGIC FOR GOTOPROP
          hashed_property[:price] = access_xml_text(item, "div.property-price").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            element_arr = access_xml_text(html, "div.specifications > div").remove_acc_scrp.tr("\n", "").split("  ").uniq
            hashed_property[:rooms_number] = element_arr[element_arr.index(" pieces :") + 1].to_int_scrp ## get the next index if the index is equal to "pieces"
            byebug if hashed_property[:rooms_number].nil?
            hashed_property[:description] = access_xml_text(html, "div.description").strip
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.informations__main > h1"), args.zone)
            hashed_property[:area] = perform_district_regex(hashed_property[:description], args.zone) if hashed_property[:area] == "N/C"
            next if hashed_property[:area] == "N/C"
            hashed_property[:images] = access_xml_link(html, "div.slideshow__preview--container > img", "src").map { |img| "https://www.vaneau.fr" + img }
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description], args.zone)
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
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
    end
    return @properties
  end
end
