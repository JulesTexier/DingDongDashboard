class Independant::ScraperCphImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.cph.fr/recherche,incl_recherche_prestige_ajax.htm?idpays=250&cp=75&surfacemin=Min&surfacemax=Max&surf_terrainmin=Min&surf_terrainmax=Max&pxmin=Min&pxmax=Max&idqfix=1&idtt=2&pres=prestige&lang=fr&idtypebien=1%2C2&tri=d_dt_crea&_=1586254200670"
    @source = "CPH Immobilier"
    @main_page_cls = "div.recherche-annonces"
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
        hashed_property[:link] = access_xml_link(item, "div.span8 > a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.recherche-annonces-infos").tr("\t\r\n", ""), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.ville-annonce"))
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.typo-body").tr("\n\r\t", "").strip, '(ce\(s\))(.?)(\d+)').to_int_scrp
        hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(item, "div.typo-body").tr("\n\r\t", "").strip, '(Chambre\(s\))(.*)(\d+)').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.prix-annonce").strip.split("\r")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.bloc-detail-descriptif").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:contact_number] = access_xml_text(html, "a.typo-white").strip.split("\r")[0].convert_phone_nbr_scrp
          hashed_property[:images] = access_xml_link(html, "#slider > a", "href")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        byebug
        next
      end
    end
    return @properties
  end
end
