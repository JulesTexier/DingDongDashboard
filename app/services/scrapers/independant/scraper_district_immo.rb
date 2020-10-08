class Independant::ScraperDistrictImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "District Immo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_text(item, "div.item-property-size").match(/(cave|parking|boutique)/i).is_a?(MatchData)
          hashed_property = {}
          hashed_property[:link] = "https://www.district-immo.com" + access_xml_link(item, "div.item-property-photo > a", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.item-property-size"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.item-property-area > p"))
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.item-property-area"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.item-property-size").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.item-property-price").split("Honoraires")[0].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.row.action-bar-property > div:nth-child(4) > p:nth-child(2)").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.row.property-gallery > div > div:nth-child(2) > ul > li > a > img", "src")
            hashed_property[:images].push(access_xml_link(html, "div.row.property-gallery > div > div > a > img", "src")[0])
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
