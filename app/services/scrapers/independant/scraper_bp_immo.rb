class Independant::ScraperBpImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Building Parners"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.lien_offres", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "a.lien_offres > h2"))
          hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '(\d+)(.?)(pieces)').to_int_scrp
          hashed_property[:surface] = access_xml_text(item, "span.surface").to_float_to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.tn-detail-desc").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "a.lien_offres > h2"))
            details = access_xml_text(html, "div.elm").strip.gsub(/[^[:print:]]/, "").gsub(" ", "").remove_acc_scrp
            hashed_property[:floor] = regex_gen(details, 'etage:(\d)*').to_int_scrp
            if details.match(/ascenseur:(oui|non)/i).is_a?(MatchData)
              regex_gen(details, "ascenseur:(oui|non)").include?("oui") ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
            end
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.item >  img", "src")
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
