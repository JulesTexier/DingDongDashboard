class Independant::ScraperDeferla < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Deferla"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://deferla.com" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.localisation > b"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "h4.text-right > a").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h4 > a"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.content > p").specific_trim_scrp("\n").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, "div.content"))
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.fancybox > img", "src")
            hashed_property[:images].collect! { |img| "https://deferla.com" + img }
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
