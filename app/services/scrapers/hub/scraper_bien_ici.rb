class Hub::ScraperBienIci < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_request, :http_type

  def initialize
    @url = "https://www.bienici.com/realEstateAds.json?filters=%7B%22size%22%3A24%2C%22from%22%3A0%2C%22filterType%22%3A%22buy%22%2C%22propertyType%22%3A%5B%22house%22%2C%22flat%22%5D%2C%22page%22%3A1%2C%22resultsPerPage%22%3A24%2C%22maxAuthorizedResults%22%3A2400%2C%22sortBy%22%3A%22publicationDate%22%2C%22sortOrder%22%3A%22desc%22%2C%22onTheMarket%22%3A%5Btrue%5D%2C%22showAllModels%22%3Afalse%2C%22zoneIdsByTypes%22%3A%7B%22zoneIds%22%3A%5B%22-7444%22%5D%7D%7D&extensionType=extendedIfNoResult&leadingCount=2&access_token=yWeDRCFt6PZ20MoXNQZcfKT3KVwyJ%2B9FIT1W3ei0Nls%3D%3A5e8468d12141c803c8845ed0&id=5e8468d12141c803c8845ed0"
    @source = "BienIci"
    @main_page_cls = ""
    @type = "HTTPRequest"
    @waiting_cls = ""
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 0
    @http_request = []
    @http_type = "get_json"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self)["realEstateAds"].each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.bienici.com/annonce/vente/" + item["id"]
        hashed_property[:surface] = item["surfaceArea"].round if item["surfaceArea"].is_a?(Integer) ## the json is sometimes an array for bad properties
        hashed_property[:area] = perform_district_regex(item["postalCode"])
        hashed_property[:rooms_number] = item["roomsQuantity"]
        hashed_property[:price] = item["price"] if item["price"].is_a?(Integer)
        next if hashed_property[:link].match(/(visiteonline-)/i).is_a?(MatchData)
        next if hashed_property[:surface].nil? || hashed_property[:price].nil?
        if go_to_prop?(hashed_property, 7)
          hashed_property[:bedrooms_number] = item["bedroomsQuantity"]
          hashed_property[:description] = item["description"]
          hashed_property[:flat_type] = item["propertyType"]
          hashed_property[:floor] = item["floorQuantity"]
          hashed_property[:has_elevator] = item["hasElevator"]
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          item["photos"].each { |img_hash| hashed_property[:images].push(img_hash["url_photo"]) }
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
