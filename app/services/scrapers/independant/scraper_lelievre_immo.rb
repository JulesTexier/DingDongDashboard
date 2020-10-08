class Independant::ScraperLelievreImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "LelievreImmo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if !item["field_annonce_type_transaction"].downcase.include?("vente")
          next if !item["field_annonce_ville"].downcase.include?("paris")
          hashed_property = {}
          hashed_property[:link] = "https://www.lelievre-immobilier.com/" + item["url"]
          hashed_property[:surface] = item["field_annonce_surface"].to_i
          hashed_property[:area] = perform_district_regex(item["field_annonce_code_postal"])
          hashed_property[:rooms_number] = item["field_annonce_pieces"]
          hashed_property[:price] = item["field_annonce_prix_brute"]
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.section_text").specific_trim_scrp("\n\r\t").strip
            hashed_property[:bedrooms_number] = item["field_annonce_chambres"]
            hashed_property[:flat_type] = get_type_flat(item["title"])
            hashed_property[:floor] = item["field_annonce_etage"] == 0 ? nil : item["field_annonce_etage"]
            hashed_property[:has_elevator] = item["field_annonce_ascenceur"] == 1 ? true : false
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = ["https://www.lelievre-immobilier.com" + item["first_image_url"]]
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
