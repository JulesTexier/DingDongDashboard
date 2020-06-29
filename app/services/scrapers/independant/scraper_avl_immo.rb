class Independant::ScraperAvlImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "AVL Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.avl-immobilier.com/" + access_xml_link(item, "a.titreBien", "href")[0].gsub("../", "")
          hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.picto-txt"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.city"))
          hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.picto-txt").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(item, "div.picto-txt").remove_acc_scrp, '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:price] = access_xml_array_to_text(item, "div.price").split("dont")[0].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.fiche-description").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33142006200"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.item-photo", "href")
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
