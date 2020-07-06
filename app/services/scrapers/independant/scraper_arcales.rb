class Independant::ScraperArcales < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Arcales"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.arcales.fr" + access_xml_link(item, "h1 > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2"))
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.col-xs-12.col-sm-5.panel-heading > ul > li:nth-child(2) > span:nth-child(2) > span:nth-child(1)"), '(\d)(.*)').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h2"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.mainContent > div:nth-child(2) > div:nth-child(1) > p").strip
            hashed_property[:agency_name] = "Arcales"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul > li > img", "src")
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
