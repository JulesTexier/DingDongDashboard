class Independant::ScraperAcopaImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr,  :http_request, :http_type

  def initialize
    @url = "https://www.acopa-immobilier.fr/wp-admin/admin-ajax.php"
    @source = "Acopa Immobilier"
    @main_page_cls = "li.annonce"
    @type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @http_request = [{}, "action=corn_realestateSearch&nonce=a96673b199&param=budget_max=10000000&surface_min=0&rooms_min=0&ville=&typetransacselected=vente&mapselected=paris&zoneselected=&lastcriteria=prix"]
    @http_type = "post"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a.thb", "href")[0].to_s
        hashed_property[:area] = perform_district_regex("Paris " + regex_gen(hashed_property[:link], 'paris(\d){1,}(\/)').to_int_scrp.to_s)
        hashed_property[:price] = access_xml_text(item, "div:nth-child(2) > div:nth-child(3) > strong:nth-child(1)").to_int_scrp
        hashed_property[:rooms_number] = access_xml_text(item, "h3").to_int_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div:nth-child(2) > div:nth-child(6) > strong:nth-child(1)"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.col-md-3:nth-child(8)").strip
          details = access_xml_text(html, '.fiche').strip.gsub(" ", "").gsub(/[^[:print:]]/, "")
          hashed_property[:bedrooms_number] = regex_gen(details, 'Chambres:(\d){1,}').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h3"))
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(item, "h3"))
          hashed_property[:agency_name] = access_xml_text(html, "#contactagences > strong")
          hashed_property[:contact_number] = access_xml_link(html, "a.tel", "href")[0].gsub(' ','').gsub("tel:","")
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          raw_images = access_xml_link(html, 'a.thb','data-image')
          hashed_property[:images] = []
          raw_images.each do |img|
            hashed_property[:images].push(img) if !img.nil?
          end
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
