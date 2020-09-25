class Independant::ScraperNestenn < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Nestenn"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          item = Nokogiri::HTML(access_xml_text(item, "div").strip.gsub(/[^[:print:]]/, ""))
          next if access_xml_link(item, ".bandeauNestenn", "src")[0] == "public/img/bandeau_compromis.png"
          hashed_property = {}
          hashed_property[:link] = "https://nestenn.com" + access_xml_link(item, "a", "href")[0].to_s
          infos = access_xml_text(item, ".infoAnnonce")
          hashed_property[:area] = perform_district_regex(infos)
          hashed_property[:price] = regex_gen(infos.tr(" ", ""), '(\d+)(€)').to_int_scrp
          hashed_property[:surface] = regex_gen(infos, '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "h2#titre").remove_acc_scrp, '(\d+)(\s)(piece(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "#annonce_detail > div:nth-child(1) > p:nth-child(4)").strip
            details = access_xml_text(html, "#groupeIcon").strip.gsub(/[^[:print:]]/, "").gsub(" ", "").remove_acc_scrp
            hashed_property[:bedrooms_number] = regex_gen(details, '(\d*)chambre').to_int_scrp
            hashed_property[:floor] = regex_gen(details, '(\d*)(er|eme)etage').to_int_scrp
            hashed_property[:has_elevator] = true if details.match(/ascenseur/i).is_a?(MatchData)
            hashed_property[:flat_type] = get_type_flat(infos)
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:agency_name] = access_xml_text(html, "#annonce_entete_left > strong:nth-child(5) > a:nth-child(1)")
            hashed_property[:contact_number] = access_xml_text(html, "#telephone_bien_content").gsub(" ", "").convert_phone_nbr_scrp
            hashed_property[:images] = access_xml_link(html, ".diapo_img > img", "src")
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
