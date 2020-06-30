class Independant::ScraperTrustInImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Trust In Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, ".recherche-annonces-lien", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".ville-annonce"))
          hashed_property[:price] = access_xml_text(item, 'span[itemprop="price"]')[0..access_xml_text(item, 'span[itemprop="price"]').length / 2].to_int_scrp
          details = access_xml_text(item, ".recherche-annonces-infos").strip.gsub(/[^[:print:]]/, "").downcase.remove_acc_scrp.gsub(" ", "")
          details = details[0..details.length / 2]
          hashed_property[:rooms_number] = regex_gen(details, "piece[(]s[)]([0123456789])*").to_int_scrp
          hashed_property[:surface] = regex_gen(details, "surface([0123456789])*").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p[itemprop='description']").strip
            hashed_property[:bedrooms_number] = regex_gen(details, "chambre[(]s[)]([0123456789])*").to_int_scrp
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div[itemprop='name']"))
            hashed_property[:agency_name] = @source
            hashed_property[:contact_number] = access_xml_text(html, "#numero-telephonez-nous-detail").gsub(" ", "").gsub(/[^[:print:]]/, "")[0..9]
            hashed_property[:floor] = access_xml_text(html, 'li[title="Etage"]').gsub(" ", "").gsub(/[^[:print:]]/, "").to_int_scrp if !access_xml_text(html, 'li[title="Etage"]').empty?
            hashed_property[:has_elevator] = access_xml_text(html, 'li[title="Ascenseur"]').include?("oui") if !access_xml_text(html, 'li[title="Ascenseur"]').empty?
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".gallery", "href")
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
