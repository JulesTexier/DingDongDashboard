class Independant::ScraperSellierPatrimoine < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Sellier Patrimoine"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.span8 > a", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.recherche-annonces-infos").tr("\t\r\n", ""), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.ville-annonce"))
          hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.typo-body").tr("\n\r\t", "").strip, '(ce\(s\))(.?)(\d+)').to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(item, "div.typo-body").tr("\n\r\t", "").strip, '(Chambre\(s\))(.*)(\d+)').to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.prix-annonce").strip.split("\r")[0].to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "span.h2-like.typo-action"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.bloc-detail-descriptif").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = "+33142750111"
            hashed_property[:images] = access_xml_link(html, "#slider > a", "href")
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
