class Independant::ScraperNestenn < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://nestenn.com/?prestige=0&action=listing&transaction=Vente&list_ville=75000+Paris%2C75001+Paris+1%2C75010+Paris+10%2C75011+Paris+11%2C75012+Paris+12%2C75013+Paris+13%2C75014+Paris+14%2C75015+Paris+15%2C75018+Paris+18%2C75002+Paris+2%2C75116+PARIS%2C75017+Paris+17%2C75016+Paris+16%2C75019+Paris+19%2C75020+Paris+20%2C75003+Paris+3%2C75004+Paris+4%2C75005+Paris+5%2C75006+Paris+6%2C75007+Paris+7&ville=75000+Paris&ville=75001+Paris+1&ville=75010+Paris+10&ville=75011+Paris+11&ville=75012+Paris+12&ville=75013+Paris+13&ville=75014+Paris+14&ville=75015+Paris+15&ville=75018+Paris+18&ville=75002+Paris+2&ville=75116+PARIS&ville=75017+Paris+17&ville=75016+Paris+16&ville=75019+Paris+19&ville=75020+Paris+20&ville=75003+Paris+3&ville=75004+Paris+4&ville=75005+Paris+5&ville=75006+Paris+6&ville=75007+Paris+7&list_type=Maison%2CAppartement%2CStudio&type=Maison&type=Appartement&type=Studio&prix_min=&prix_max=&pieces=&chambres=&surface_min=&surface_max=&surface_terrain_min=&surface_terrain_max=&ref="
    @source = "Nestenn"
    @main_page_cls = ".annonce"
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
      item = Nokogiri::HTML(access_xml_text(item, 'div').strip.gsub(/[^[:print:]]/, ""))
      next if access_xml_link(item, '.bandeauNestenn','src')[0] == "public/img/bandeau_compromis.png"
      hashed_property = {}
      hashed_property[:link] = "https://nestenn.com" + access_xml_link(item, "a", "href")[0].to_s
      infos = access_xml_text(item, '.infoAnnonce')
      hashed_property[:area] = perform_district_regex(infos)
      hashed_property[:price] = regex_gen(infos, '(\d)(.*)(€)').to_int_scrp
      hashed_property[:surface] = regex_gen(infos, '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "h2#titre").remove_acc_scrp, '(\d+)(\s)(piece(s?))').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "#annonce_detail > div:nth-child(1) > p:nth-child(4)").strip
          details = access_xml_text(html, '#groupeIcon').strip.gsub(/[^[:print:]]/, "").gsub(' ','').remove_acc_scrp
          hashed_property[:bedrooms_number] = regex_gen(details, '(\d*)chambre').to_int_scrp
          hashed_property[:floor] = regex_gen(details, '(\d*)(er|eme)etage').to_int_scrp
          details.match(/ascenseur/i).is_a?(MatchData) ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:flat_type] = get_type_flat(infos)
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] =access_xml_text(html, '#annonce_entete_left > strong:nth-child(5) > a:nth-child(1)')
          hashed_property[:contact_number] = access_xml_text(html, '#telephone_bien_content').gsub(' ','')
          hashed_property[:images] = access_xml_link(html, '.diapo_img > img', 'src')
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
