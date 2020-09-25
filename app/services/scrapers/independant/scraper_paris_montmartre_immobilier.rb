class Independant::ScraperParisMontmartreImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Paris Montmartre Immo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, ".property-title>a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".property-title>a"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".property-title"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(item.text, '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            detail = access_xml_text(html, "#detail").strip.tr(" ", "")
            hashed_property[:flat_type] = "N/C"
            hashed_property[:bedrooms_number] = regex_gen(detail, 'Chambre(s?):(\d)*').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "#description>p").strip
            hashed_property[:agency_name] = @source
            hashed_property[:floor] = regex_gen(detail, 'Etage(s?):(\d)*').to_int_scrp
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.sp-image", "src")
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
