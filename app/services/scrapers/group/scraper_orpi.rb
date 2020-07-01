class Group::ScraperOrpi < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Orpi"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = 13)
    i = 0
    self.params.each do |args|
      fetch_main_page(args)["items"].each do |item|
        begin
          next if item["sold"]
          hashed_property = {}
          hashed_property[:link] = "https://www.orpi.com/annonce-vente-" + item["slug"]
          hashed_property[:surface] = item["surface"].to_i
          hashed_property[:area] = perform_district_regex(item["locationDescription"], args.zone)
          hashed_property[:rooms_number] = item["nbRooms"]
          hashed_property[:price] = item["price"].to_i
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            details = access_xml_text(html, "#collapse-details").strip.gsub(/[^[:print:]]/, "").gsub(" ", "").remove_acc_scrp
            hashed_property[:rooms_number] == 1 ? hashed_property[:bedrooms_number] = 0 : hashed_property[:bedrooms_number] = regex_gen(details, '(\d){1,}chambre').to_int_scrp
            hashed_property[:floor] = regex_gen(details, 'etage(\d){1,}').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "div.o-container > p:nth-child(2)").specific_trim_scrp("\n\r").strip
            hashed_property[:flat_type] = regex_gen(access_xml_text(html, "span.u-text-xl"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
            details.match(/ascenseur/i).is_a?(MatchData) ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = item["images"]
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
