class Independant::ScraperCeiCab < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.cei-cab.com/annonces?id_polygon=&localisation_etendu=1&visite_virtuelle=&categorie=vente&type_bien=appartement&nb_pieces=&surface=&budget=&localisation=Paris+%2875%29&submit=Rechercher"
    @source = "Cei Cab"
    @main_page_cls = "div.container-offre"
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
        title = access_xml_text(item, 'h2[itemprop="name"]').gsub(" ", "").gsub(/[^[:print:]]/, "")
        next if (access_xml_text(item, ".vignette-compromis").downcase.include?("compromis") || !access_xml_text(item, "h3").downcase.include?("paris"))
        hashed_property[:link] = "https://www.cei-cab.com" + access_xml_link(item, 'h2[itemprop="name"] > a', "href")[0]
        hashed_property[:surface] = access_xml_text(item, ".surface").to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h3"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, 'h2[itemprop="name"]').gsub(" ", "").gsub(/[^[:print:]]/, ""), '(\d)*pi').to_int_scrp
        hashed_property[:price] = access_xml_link(item, "span[itemprop='price']", "content")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:bedrooms_number] = access_xml_text(html, ".chambre").to_int_scrp
          hashed_property[:description] = access_xml_text(html, 'p[itemprop="description"]').strip
          hashed_property[:floor] = access_xml_text(html, "div.caracteristique-bloc:nth-child(4) > ul:nth-child(2) > li:nth-child(5) > strong").to_int_scrp
          if access_xml_text(html, ".caracteristiques-divers").gsub(" ", "").downcase.gsub(/[^[:print:]]/, "").match(/ascenseur:oui/i).is_a?(MatchData)
            hashed_property[:has_elevator] = true
          else
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          end
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(html, ".negociateur-infos > h3")
          hashed_property[:images] = access_xml_link(html, "div#photoslider > ul > li > a", "href")
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
