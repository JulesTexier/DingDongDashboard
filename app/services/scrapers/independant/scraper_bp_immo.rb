class Independant::ScraperBpImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_request, :http_type

  def initialize
    @url = "https://www.bpimmo.com/recherche.php"
    @source = "Building Parners"
    @main_page_cls = "div.offre_bien"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
     @http_request = [{}, { "ville[]" => "75008", "rechercher" => "Rechercher"  }]
    @http_type = "post"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a.lien_offres", "href")[0].to_s
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "a.lien_offres > h2"))
        hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
        hashed_property[:rooms_number] = access_xml_text(item, "span.nb_ch").to_int_scrp + 1
        hashed_property[:surface] = access_xml_text(item, "span.surface").to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:bedrooms_number] = hashed_property[:rooms_number] - 1
          hashed_property[:description] = access_xml_text(html, "div.tn-detail-desc").strip
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "a.lien_offres > h2"))

          details = access_xml_text(html, 'div.elm').strip.gsub(/[^[:print:]]/, "").gsub(' ','').remove_acc_scrp
          hashed_property[:floor] = regex_gen(details, 'etage:(\d)*').to_int_scrp
          if details.match(/ascenseur:(oui|non)/i).is_a?(MatchData) 
            regex_gen(details, 'ascenseur:(oui|non)').include?('oui') ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
          else 
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          end

          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source

          hashed_property[:images] = access_xml_link(html, 'div.item >  img', 'src')
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
