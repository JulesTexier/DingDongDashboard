class Independant::ScraperGaranceImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Garance Immobilier"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.row > a", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "span.icon_surface").gsub(/[[:space:]]/i, "").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h4"))
          hashed_property[:rooms_number] = access_xml_text(item, "span.icon_pieces").gsub(/[[:space:]]/i, "").to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_text(item, "span.icon_chambres").gsub(/[[:space:]]/i, "").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "h4:nth-child(20)").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.col-md-6.col-xs-12 > div:nth-child(2)").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = access_xml_text(html, "h4.panel-title > strong").gsub(".", "").convert_phone_nbr_scrp
            hashed_property[:images] = access_xml_link(html, "a.fancybox", "href").map { |img| "http://www.garance-immo.com" + img }
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
