class Independant::ScraperHomizy < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Homizy"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.homizy-immobilier.com" + access_xml_link(item, "article", "onclick")[0].to_s.gsub("location.href='", "").gsub("'", "")
          hashed_property[:surface] = regex_gen(access_xml_text(item, "header.lstbody > h2"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.ville > span"))
          next if hashed_property[:area] == "N/C"
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "header.lstbody > h2").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.left-caption > span:nth-child(2) > span:nth-child(1)").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "header.lstbody > h2"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "article.elementDt > p").specific_trim_scrp("\n").strip.gsub("L'équipe d'Homizy se tient à votre disposition par téléphone ou par mail pour répondre à vos questions et organiser une visite. Notre commission de commercialisation est de 4 500 euros fixe, à la charge du vendeur.", "")
            property_data = access_xml_array_to_text(html, "div.tab-pane > p").gsub("\n", "").gsub(" ", "")
            hashed_property[:floor] = regex_gen(property_data, 'Etage\d').gsub("Etage", "").to_int_scrp
            elevator_raw = regex_gen(property_data, "Ascenseur(OUI|NON)").gsub("Ascenseur", "")
            elevator_raw == "OUI" ? hashed_property[:has_elevator] = true : nil
            elevator_raw == "NON" ? hashed_property[:has_elevator] = false : nil
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "li > img", "src")
            hashed_property[:images].collect! { |img| "https:" + img }
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
