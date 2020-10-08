class Independant::ScraperEngelVoelkers < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Engel Voelkers"
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
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.ev-teaser-attributes > div:last-child"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.ev-value"), '(\d)(.*)').to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".ev-teaser-subtitle"))
          next if hashed_property[:area] == "N/C"
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(html, "ul.ev-exposee-detail-facts"), 'Pi(e|è)ce(s?)(.?)(\d+)').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "p.ev-exposee-text").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, ".ev-exposee-subtitle"))
            hashed_property[:agency_name] = "Engel Voelkers"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.ev-image-gallery-image", "src")
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
