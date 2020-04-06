class ScraperErnest < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.ernest-et-associes.com/catalog/advanced_search_result.php?action=update_search&search_id=&map_polygone=&C_28_search=EGAL&C_28_type=UNIQUE&C_28=Vente&C_27_search=EGAL&C_27_type=TEXT&C_27=&C_34=0&C_34_search=COMPRIS&C_34_type=NUMBER&C_34_MIN=&C_34_MAX=&C_30_MAX=&C_65_search=CONTIENT&C_65_type=TEXT&C_65=75&C_65_temp=75"
    @source = "Ernest et associés"
    @main_page_cls = "div.content_liste_vente"
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
        next if access_xml_text(item, "div.content_liste_texte > div:nth-child(1) > h2 > a").downcase.include?("vendu")
        hashed_property[:link] = "http://www.ernest-et-associes.com" + access_xml_link(item, ".content_liste_vente_voir > a", "href")[0].to_s.gsub("..", "")
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
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
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
