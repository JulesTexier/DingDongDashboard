class ScraperOrpi < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_type

  def initialize
    @url = "https://www.orpi.com/recherche/ajax/buy?realEstateTypes%5B%5D=maison&realEstateTypes%5B%5D=appartement&locations%5B0%5D%5Bvalue%5D=paris&locations%5B0%5D%5Blabel%5D=Paris&minSurface=10&maxSurface=1000&nbRooms%5B%5D=1&nbRooms%5B%5D=2&nbRooms%5B%5D=3&nbRooms%5B%5D=4&nbRooms%5B%5D=5&nbRooms%5B%5D=6&newBuild=true&oldBuild=true&minPrice=0&maxPrice=7000000&sort=date-down&layoutType=list"
    @source = "Orpi"
    @main_page_cls = "div.c-box__inner.c-box__inner--sm"
    @type = "HTTPRequest"
    @waiting_cls = "u-mt-md"
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 0,
    @http_type = "get_json"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self)["items"].each do |item|
      begin
        next if item["sold"]
        hashed_property = {}
        hashed_property[:link] = "https://www.orpi.com/annonce-vente-" + item["slug"]
        hashed_property[:surface] = item["surface"].to_i
        hashed_property[:area] = perform_district_regex(item["locationDescription"])
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
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = item["images"]
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
