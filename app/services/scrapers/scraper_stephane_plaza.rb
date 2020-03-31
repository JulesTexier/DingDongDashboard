class ScraperStephanePlaza < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.stephaneplazaimmobilier.com/search/buy?target=buy&type[]=1&type[]=2&location[]=75&sort=date_desc&limit=15"
    @source = "Stephane Plaza"
    @main_page_cls = ""
    @type = ""
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    token = fetch_json(self)["token"]
    fetch_json(self)["results"].each do |property|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.stephaneplazaimmobilier.com/immobilier-acheter/" + property["id"].to_s + "/" + property["slug"].to_s + "?token=" + token
        hashed_property[:surface] = regex_gen(property["properties"]["surface"], '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = property["properties"]["codePostal"]
        hashed_property[:rooms_number] = property["properties"]["room"]
        hashed_property[:price] = property["price"].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          hashed_property[:bedrooms_number] = property["properties"]["bedroom"]
          hashed_property[:description] = property["description"]
          if property["type"] == "1"
            hashed_property[:flat_type] = "Appartmement"
          elsif property["type"] == "2"
            hashed_property[:flat_type] = "Maison"
          else
            hashed_property[:flat_type] = "N/C"
          end
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = property["properties"]["floor"]
          hashed_property[:has_elevator] = property["properties"]["lift"]
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = property["thumbnails"]
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
