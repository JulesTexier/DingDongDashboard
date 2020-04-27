class Hub::ScraperProprietesFigaro < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Propr. Figaro"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page_multi_city(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://proprietes.lefigaro.fr" + access_xml_link(item, "h2.h2-like > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.itemlist-infos > ul > li:nth-child(1) > span.nb"), '(\d+(.?)(\d*))').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.itemlist-localisation > span"), args["zone"])
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(item, "ul.itemlist-caracteristiques"), '(\d+(.?)(?=chambres))').to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.itemlist-infos > ul > li:nth-child(2) > span.nb"), '(\d+(.?)(\d*))').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "span.itemlist-price-nb").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "span.itemlist-title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#js-description").specific_trim_scrp("\n").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description], args["zone"])
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.owl-lazy", "data-src")
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
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
