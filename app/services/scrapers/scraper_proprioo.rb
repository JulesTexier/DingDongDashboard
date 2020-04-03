class ScraperProprioo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_request, :http_type

  def initialize
    @url = "https://9zx8d1ab8c-dsn.algolia.net/1/indexes/*/queries?x-algolia-agent=Algolia%20for%20JavaScript%20(4.1.0)%3B%20Browser%20(lite)%3B%20JS%20Helper%20(3.1.1)%3B%20react%20(16.13.1)%3B%20react-instantsearch%20(6.4.0)&x-algolia-api-key=b848f214a86e4735a9801b9a0aad971b&x-algolia-application-id=9ZX8D1AB8C"
    @source = "Proprioo"
    @main_page_cls = "div.sc-1y2l6jx-0"
    @type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @wait = 1
    @page_nbr = 1
    @properties = []
    @http_type = "post_json"
    @http_request = [{}, '{"requests":[{"indexName":"prod_listings","params":"highlightPreTag=%3Cais-highlight-0000000000%3E&highlightPostTag=%3C%2Fais-highlight-0000000000%3E&hitsPerPage=18&filters=surface%20%3C%3D%2010000%20AND%20localisation%3A%22Paris%22&attributesToHighlight=%5B%5D&page=0&facets=%5B%5D&tagFilters="}]}']
  end

  def launch(limit = nil)
    i = 0
    json = fetch_main_page(self)
    json["results"][0].each do |array|
      if array[1].is_a?(Array)
        begin
          array[1].each do |item|
            hashed_property = {}
            hashed_property[:link] = "https://proprioo.fr" + I18n.transliterate(item["uri"])
            hashed_property[:surface] = item["surface"].round
            hashed_property[:price] = item["prix"]
            hashed_property[:rooms_number] = item["nbPieces"]
            hashed_property[:area] = item["codePostal"]
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
          rescue StandardError => e
            puts "\nError for #{@source}, skip this one."
            puts "It could be a bad link or a bad xml extraction.\n\n"
            next
          end
        end
      end
    end
    return @properties
  end
end
