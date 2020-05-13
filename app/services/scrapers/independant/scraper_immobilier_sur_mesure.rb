class Independant::ScraperImmobilierSurMesure < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Immo Sur Mesure"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "a > p:nth-child(3)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "a > p:nth-child(2)"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "a > p:nth-child(4)"), '(Pi(è|e)ce(s?) :)(.?)(\d+)').tr("^0-9", "").to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '(\d+)(-?)(piece(s?))').to_int_scrp if hashed_property[:rooms_number] == 0
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "a > h2"))
          hashed_property[:area] = perform_district_regex(hashed_property[:link]) if hashed_property[:area] == "N/C"
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.infos-long > h2")) if hashed_property[:area] == "N/C"
            next if hashed_property[:area] == "N/C"
            hashed_property[:description] = access_xml_text(html, ".text-bien > p").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(html, "strong.bread-current"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:agency_name] = "Immo Sur Mesure"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.single-bien-image > img", "src")
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
