class Independant::ScraperAuburtinImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Auburtin Immo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div:nth-child(1) > div:nth-child(1) > a", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.ville-annonce"))
          raw_price = access_xml_text(item, "div.prix-annonce")
          hashed_property[:price] = raw_price[0..raw_price.length / 2].to_int_scrp
          details = access_xml_text(item, "div:nth-child(1) > div:nth-child(2) > a:nth-child(1) > div:nth-child(1) > p:nth-child(1)").gsub(" ", "").gsub(/[^[:print:]]/, "")
          hashed_property[:rooms_number] = regex_gen(details, '(\d)*(pi)').to_int_scrp
          hashed_property[:surface] = regex_gen(details, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.bloc-detail-descriptif").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div:nth-child(1) > div:nth-child(2) > a:nth-child(1) > div:nth-child(1) > p:nth-child(1) > span:nth-child(1)"))
            hashed_property[:bedrooms_number] = access_xml_text(html, 'li[title="Chambres"]').to_int_scrp if !access_xml_text(html, 'li[title="Chambres"]').empty?
            hashed_property[:floor] = access_xml_text(html, 'li[title="Etage"]').to_int_scrp if !access_xml_text(html, 'li[title="Etage"]').empty?
            if !access_xml_text(html, 'li[title="Ascenseur"]').empty?
              access_xml_text(html, 'li[title="Ascenseur"]').match(/oui/i).is_a?(MatchData) ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
            end
            hashed_property[:provider] = "Agence"
            hashed_property[:agency_name] = "AUBURTIN IMMOBILIER - Marx Dormoy"
            hashed_property[:contact_number] = "+33142058403"
            hashed_property[:source] = @source
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
