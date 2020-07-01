class Independant::ScraperErnest < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Ernest et associés"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          next if access_xml_text(item, "div.content_liste_texte > div:nth-child(1) > h2 > a").downcase.include?("vendu")
          link = "http://www.ernest-et-associes.com" + access_xml_link(item, ".content_liste_vente_voir > a", "href")[0].to_s.gsub("..", "")
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".description_annonce"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.content_liste_texte > div:nth-child(1) > h2 > a"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".description_annonce"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".content_liste_prix").strip.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            card = access_xml_text(html, "#content_details")
            hashed_property[:surface] = regex_gen(card, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp if hashed_property[:surface] == 0
            hashed_property[:rooms_number] = regex_gen(card.remove_acc_scrp, 'Piece(s*) : \d*').to_int_scrp if hashed_property[:rooms_number] == 0
            hashed_property[:bedrooms_number] = regex_gen(card, 'Chambre(s*) : \d*').to_int_scrp
            hashed_property[:flat_type] = get_type_flat(regex_gen(card, "Type : (.)*Ville"))
            hashed_property[:description] = access_xml_text(html, ".content_details_description").strip
            hashed_property[:agency_name] = @source
            hashed_property[:subway_infos] = perform_subway_regex(access_xml_text(html, ".localisation"))
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            raw_images = access_xml_link(html, ".slides > li > a", "href")
            raw_images.each do |img|
              if img.include?("../office8/ernest_et_associes")
                hashed_property[:images].push(img.gsub("..", "http://www.ernest-et-associes.com"))
              end
            end
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
