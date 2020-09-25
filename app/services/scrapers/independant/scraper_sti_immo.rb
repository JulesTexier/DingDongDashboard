class Independant::ScraperStiImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "STI Immo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          clean_title = access_xml_text(item, "p[itemprop='description']").strip.gsub(/[^[:print:]]/, "").gsub(" ", "").remove_acc_scrp
          next unless clean_title.include?("appartement") || clean_title.include?("studio")
          next unless clean_title.match(/paris/i).is_a?(MatchData)
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p[itemprop='description']"))
          hashed_property[:link] = "http://www.sti-immo.com" + access_xml_link(item, "a:nth-child(1)", "href")[0].to_s
          hashed_property[:price] = access_xml_text(item, "span[itemprop='price']").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(clean_title, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
          hashed_property[:surface] = regex_gen(clean_title, '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.description").strip
            details = access_xml_text(html, "#infos").strip.gsub(/[^[:print:]]/, "").downcase.gsub(" ", "").remove_acc_scrp
            hashed_property[:floor] = regex_gen(details, 'etage(\d)*').to_int_scrp if details.match(/etage(\d)*/i).is_a?(MatchData)
            hashed_property[:has_elevator] = regex_gen(details, "ascenseur(oui|non)").include?("oui") if details.match(/ascenseur(oui|non)/i).is_a?(MatchData)
            hashed_property[:bedrooms_number] = access_xml_text(html, ".little-infos > div:nth-child(3) > div:nth-child(2) > h5:nth-child(1)").to_int_scrp
            hashed_property[:flat_type] = get_type_flat(clean_title)
            hashed_property[:agency_name] = access_xml_text(html, ".agence > div >  h5")
            hashed_property[:contact_number] = access_xml_text(html, "span.telagence").gsub(" ", "").gsub(/[^[:print:]]/, "").convert_phone_nbr_scrp
            hashed_property[:subway_infos] = perform_subway_regex(access_xml_text(html, 'h1[itemprop="name"]') + hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".imgBien", "src").map { |img| "https:" + img }
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
