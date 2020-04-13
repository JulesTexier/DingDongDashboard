class ScraperLelievreImmo < Scraper
    attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_type, :http_request
  
    def initialize
      @url = "https://www.lelievre-immobilier.com/sites/default/files/annonces/json/allAnnonces.json?"
      @source = "LelievreImmo"
      @main_page_cls = ""
      @type = "HTTPRequest"
      @waiting_cls = nil
      @multi_page = false
      @page_nbr = 1
      @properties = []
      @http_request = [{}, {}]
      @http_type = "get_json"
    end
  
    def launch(limit = nil)
      i = 0
      fetch_main_page(self).each do |item|
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
            hashed_property[:flat_type] = regex_gen(item["title"], "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
            hashed_property[:floor] = item["field_annonce_etage"] == 0 ? nil : item["field_annonce_etage"]
            hashed_property[:has_elevator] = item["field_annonce_ascenceur"] == 1 ? true : false
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = ["https://www.lelievre-immobilier.com" + item["first_image_url"]]
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
            i += 1
            break if i == limit
          end
        rescue StandardError => e
          error_outputs(e, @source)
          next
        end
        puts JSON.pretty_generate(hashed_property)
      end
      return @properties
    end
  end
  