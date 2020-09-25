class Independant::ScraperImmobilierParisien < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Immobilier Parisien"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.ContourBiensListe > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "p.text-right"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.localisation"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.content > p").tr("\n\r\t", "").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h4 > a"))
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.carousel-inner > div > a > img", "src").map { |img| "http://www.immobilier-parisien.fr" + img }
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
