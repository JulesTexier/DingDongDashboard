class Independant::ScraperProprioo < Scraper
  attr_accessor :source, :params, :properties

  def initialize
    @source = "Proprioo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      json = fetch_main_page(args)
      json["results"][0].each do |array|
        if array[1].is_a?(Array)
          begin
            array[1].each do |item|
              hashed_property = {}
              hashed_property[:link] = "https://proprioo.fr" + I18n.transliterate(item["uri"])
              hashed_property[:surface] = item["surface"].round
              hashed_property[:price] = item["prix"]
              hashed_property[:rooms_number] = item["nbPieces"]
              hashed_property[:area] = perform_district_regex(item["codePostal"])
              if go_to_prop?(hashed_property, 7)
                desc = access_xml_text(fetch_static_page(hashed_property[:link]), "div.j6vkol-0").to_s.strip
                desc.gsub("Proprioo vous propose à la vente", "").gsub("Proprioo, l’agence nouvelle génération, vous propose à la vente", "")
                hashed_property[:description] = desc
                hashed_property[:flat_type] = item["typeBien"]
                hashed_property[:bedrooms_number] = item["nbBedrooms"]
                hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
                hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
                hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
                hashed_property[:provider] = "Agence"
                hashed_property[:source] = @source
                hashed_property[:images] = item["thumbnails"]
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
      end
    end
    return @properties
  end
end