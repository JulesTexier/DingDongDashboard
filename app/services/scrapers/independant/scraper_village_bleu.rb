class Independant::ScraperVillageBleu < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Village Bleu"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".annonce-surface"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".annonce-pieces"), "([0-9]){1,}").to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".annonce-prix").strip.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.detail-desc-txt").strip
            details = access_xml_text(html, ".detail-sign").strip.gsub(" ", "").gsub(/[^[:print:]]/, "").downcase.remove_acc_scrp
            hashed_property[:bedrooms_number] = regex_gen(details, 'chambre(s){0,}(\d){1,}').to_int_scrp
            hashed_property[:flat_type] = "Appartement"
            floor = regex_gen(details, 'etage{0,}((\d){1,}|rdc)').gsub("etage", "")
            floor == "rdc" ? hashed_property[:floor] = 0 : hashed_property[:floor] = floor.to_int_scrp
            elevator = regex_gen(details, "ascenseuroui").gsub("ascenseur", "")
            elevator == "oui" ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            images = access_xml_link(html, ".detail-galerie-item", "style")
            images.each do |img|
              hashed_property[:images].push(regex_gen(img, "https(.)*.jpg"))
            end
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
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
