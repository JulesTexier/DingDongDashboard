class Group::ScraperDavidImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "DavidImmo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".icon_surface"), '(\d)(.)').to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "a > div > h4:nth-child(20)"), '(\d)(.*)(€)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".icon_pieces"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "a > div > h4:nth-child(2)").tr("^0-9", ""))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#main > div:nth-child(1) > div:nth-child(1) > div:nth-child(2)").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h1"))
            hashed_property[:flat_type] = get_type_flat(hashed_property[:link]) if hashed_property[:flat_type] == "N/C"
            hashed_property[:agency_name] = "DavidImmo"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_link(html, "div.full_image", "style").each do |img|
              hashed_property[:images].push(img.split("url(")[1].chop.chop)
            end
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
