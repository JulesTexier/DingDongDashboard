class Independant::ScraperCheneVert < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Chene Vert"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.le-chene-vert.com/" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.cbp-l-caption-body > div.btn-u"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.cbp-l-caption-body"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:rooms_number] == 0 && hashed_property[:rooms_number] = 1
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.cbp-l-caption-body"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:surface] = regex_gen(access_xml_text(html, "h4"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
            hashed_property[:description] = access_xml_text(html, "div.tag-box > p").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_raw(item, "img")[0].values[1])
            hashed_property[:agency_name] = "Chene Vert"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "span.overlay-zoom > img", "src")
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
