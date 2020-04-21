class Independant::ScraperParisPrestigeImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_request, :http_type

  def initialize
    @url = "http://www.parisprestigeimmo.fr/fr/recherche/"
    @source = "Paris prestige immo"
    @main_page_cls = "li.ad"
    @type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @http_type = "post"
    @http_request = [{}, "nature=1&type%5B%5D=1&type%5B%5D=2&city%5B%5D=32550&city%5B%5D=32551&city%5B%5D=32552&city%5B%5D=32553&city%5B%5D=32554&city%5B%5D=32555&city%5B%5D=32556&city%5B%5D=32557&city%5B%5D=32558&city%5B%5D=32559&city%5B%5D=32560&city&city%5B%5D=32561&city%5B%5D=32562&city%5B%5D=32563&city%5B%5D=32564&city%5B%5D=32565&city%5B%5D=32566&city%5B%5D=32567&city%5B%5D=32568&city%5B%5D=32569&price=&age=&tenant_min=&tenant_max=&rent_type=&currency=EUR&homepage="]
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "http://www.parisprestigeimmo.fr" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:area] = perform_district_regex(hashed_property[:link])
        hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '-(\d){1,}-piece').to_int_scrp
        hashed_property[:price] = access_xml_text(item, ".price").strip.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "article > p.comment").gsub(/[^[:print:]]/, "").strip
          details = access_xml_text(html, ".summary > ul:nth-child(2)").gsub(/[^[:print:]]/, "").downcase.gsub(" ", "").remove_acc_scrp
          hashed_property[:surface] = regex_gen(details, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:floor] = regex_gen(details, 'etage(\d){1,}e').to_int_scrp
          raw_bedrooms = hashed_property[:description].transform_litteral_numbers.gsub(" ", "")
          hashed_property[:bedrooms_number] = regex_gen(raw_bedrooms, '(\d){1,}chambre').to_int_scrp if raw_bedrooms.match(/(\d){1,}chambre/i).is_a?(MatchData)
          hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".title > h1") + hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:agency_name] = access_xml_text(html, "aside  > h4")
          hashed_property[:contact_number] = access_xml_link(html, "aside  > p > a", "href")[0].gsub("tel:0033", "").convert_phone_nbr_scrp
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".slideshow > img", "src")
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
