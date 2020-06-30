class Independant::ScraperAmourImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Amour Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = item["href"]
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".surface"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "h5"), '(\d)(.*)').to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h4").tr("/", ""))
          next if hashed_property[:area] == "N/C"
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, ".titrecaracteristiquedubien > ul"), '(Pi(è|e)ce(s?))(...)(\d+)').tr("^0-9", "").to_float_to_int_scrp
            hashed_property[:description] = access_xml_text(html, ".description").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2 > .categ"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:agency_name] = "Amour Immobilier"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul.slides > li > img", "src")
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
