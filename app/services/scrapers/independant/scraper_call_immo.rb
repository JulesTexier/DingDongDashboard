class Independant::ScraperCallImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Callimmo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.callimmo.fr" + access_xml_link(item, "div.overlay-container > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "ul.inline-list"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.vertical-align > h2"))
          next if hashed_property[:area] == "N/C"
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.vertical-align > h2").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.vertical-align > h3"), '(\d)(.*)(€)').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.vertical-align > h2"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.read-more").specific_trim_scrp("\n").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = ["http://www.callimmo.fr" + access_xml_link(html, "li.clearing-featured-img.small-12.margin-no > div > a", "href")[0].to_s]
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
