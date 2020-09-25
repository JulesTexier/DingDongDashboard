class Independant::ScraperCeiCab < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Cei Cab"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          title = access_xml_text(item, 'h2[itemprop="name"]').gsub(" ", "").gsub(/[^[:print:]]/, "")
          next if (access_xml_text(item, ".vignette-compromis").downcase.include?("compromis") || !access_xml_text(item, "h3").downcase.include?("paris"))
          hashed_property[:link] = "https://www.cei-cab.com" + access_xml_link(item, 'h2[itemprop="name"] > a', "href")[0]
          hashed_property[:surface] = access_xml_text(item, ".surface").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h3"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, 'h2[itemprop="name"]').gsub(" ", "").gsub(/[^[:print:]]/, ""), '(\d)*pi').to_int_scrp
          hashed_property[:price] = access_xml_link(item, "span[itemprop='price']", "content")[0].to_int_scrp
          hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:bedrooms_number] = access_xml_text(html, ".chambre").to_int_scrp
            hashed_property[:description] = access_xml_text(html, 'p[itemprop="description"]').strip
            hashed_property[:floor] = access_xml_text(html, "div.caracteristique-bloc:nth-child(4) > ul:nth-child(2) > li:nth-child(5) > strong").to_int_scrp
            hashed_property[:has_elevator] = true if access_xml_text(html, ".caracteristiques-divers").gsub(" ", "").downcase.gsub(/[^[:print:]]/, "").match(/ascenseur:oui/i).is_a?(MatchData)
            hashed_property[:subway_infos] = perform_subway_regex(access_xml_text(html, ".localisation"))
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:agency_name] = access_xml_text(html, ".negociateur-infos > h3")
            hashed_property[:images] = access_xml_link(html, "div#photoslider > ul > li > a", "href")
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
