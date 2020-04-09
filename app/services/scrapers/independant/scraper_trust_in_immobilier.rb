class Independant::ScraperTrustInImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.trust-in-immobilier.fr/recherche,basic.htm?ci=750056&idqfix=1&idtt=2&idtypebien=2&idtypebien=1&pxmax=Max&pxmin=Min&saisie=O%C3%B9+d%C3%A9sirez-vous+habiter+%3f&surfacemax=Max&surfacemin=Min&tri=d_dt_crea&"
    @source = "Trust In Immobilier"
    @main_page_cls = "div.conteneur-annonce"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, ".recherche-annonces-lien", "href")[0].to_s
        hashed_property[:area] = perform_district_regex(access_xml_text(item, ".ville-annonce"))
        hashed_property[:price] = access_xml_text(item, 'span[itemprop="price"]')[0..access_xml_text(item, 'span[itemprop="price"]').length/2].to_int_scrp
        details = access_xml_text(item, '.recherche-annonces-infos').strip.gsub(/[^[:print:]]/, "").downcase.remove_acc_scrp.gsub(' ','')
        details = details[0..details.length/2]
        hashed_property[:rooms_number] = regex_gen(details, "piece[(]s[)]([0123456789])*").to_int_scrp
        hashed_property[:surface] = regex_gen(details, "surface([0123456789])*").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p[itemprop='description']").strip
            hashed_property[:bedrooms_number] = regex_gen(details, "chambre[(]s[)]([0123456789])*").to_int_scrp
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div[itemprop='name']"))
            hashed_property[:agency_name] = @source
            hashed_property[:contact_number] = access_xml_text(html, "#numero-telephonez-nous-detail").gsub(' ','').gsub(/[^[:print:]]/, "")[0..9]
            if !access_xml_text(html, 'li[title="Etage"]').empty?
              hashed_property[:floor] = access_xml_text(html, 'li[title="Etage"]').gsub(' ','').gsub(/[^[:print:]]/, "").to_int_scrp
            else 
              perform_floor_regex(hashed_property[:description])
            end
            if !access_xml_text(html, 'li[title="Ascenseur"]').empty?
              access_xml_text(html, 'li[title="Ascenseur"]').include?('oui') ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
            else 
              hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            end
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".gallery", "href")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
