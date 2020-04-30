class Group::ScraperArthurimmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.arthurimmo.com/recherche,incl_recherche_prestige_ajax.htm?idpays=250&ci=750056&surfacemin=Min&surfacemax=Max&surf_terrainmin=Min&surf_terrainmax=Max&idqfix=1&idtt=2&pres=prestige&lang=fr&tri=d_dt_crea%2Cd_dt_crea&idtypebien=1%2C2&tri=d_dt_crea&_=1587115724817"
    @source = "Arthurimmo"
    @main_page_cls = "div.recherche-annonces-vente"
    @scraper_type = "Static"
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
        hashed_property[:link] = access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.annonces-carac > div.annonces-carac-item:nth-child(1)"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.ville-annonce"))
        hashed_property[:rooms_number] = access_xml_text(item, "div.annonces-carac > div.annonces-carac-item:nth-child(2)").to_int_scrp
        hashed_property[:bedrooms_number] = access_xml_text(item, "div.annonces-carac > div.annonces-carac-item:nth-child(3)").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.prix-annonce > span").strip.to_int_scrp
        hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
        next if hashed_property[:flat_type] == "Bureaux"
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.detail-accordeon-item-txt > p").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(html, 'div[itemprop="name"]')
          hashed_property[:contact_number] = access_xml_text(html, "#numero-telephonez-nous-detail").gsub(" ", "").gsub(/[^[:print:]]/, "")[0..9].convert_phone_nbr_scrp
          hashed_property[:images] = access_xml_link(html, "div.item > img", "src").map { |img| img.gsub("h_175,w_175", "h_600,w_800") }
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
