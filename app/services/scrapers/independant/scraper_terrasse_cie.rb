class Independant::ScraperTerrasseCie < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "TerrasseCie"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.terrasse-cie.com" + access_xml_link(item, "a.button", "href")[1].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2"))
          hashed_property[:surface] = regex_gen(access_xml_text(item, "li.area"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "li.price > div"), '(\d)(.*)').to_int_scrp != 0 ? regex_gen(access_xml_text(item, "li.price > div"), '(\d)(.*)').to_int_scrp : nil
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(html, ".summary > ul"), '(\d+)(.?)(PI(È|e)CE(S?))').to_float_to_int_scrp
            hashed_property[:description] = access_xml_text(html, "p.comment").strip
            hashed_property[:agency_name] = "Terrasse Cie"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".slideshow > img", "src")
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
