class Independant::ScraperDauphineImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.dauphine-immo.com/advanced-search/?type=&max-price=&status=vente&location=&bathrooms=&min-area=&max-area=&min-price=&max-price=&property_id="
    @source = "Dauphine Immo"
    @main_page_cls = "div.property-item"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a:nth-child(1)", "href")[0].to_s
        title = access_xml_text(item, ".property-title")
        hashed_property[:area] = regex_gen(title.gsub(' ',''),'(\d){1,}e').to_int_scrp.to_s.district_generator_scrp
        if get_type_flat(title) == "Studio"
          hashed_property[:rooms_number] = 1
          hashed_property[:bedrooms_number] = 1
        else
          hashed_property[:rooms_number] = regex_gen(title.gsub(' ',''),'(\d){1,}pi').to_int_scrp
        end
        hashed_property[:price] = access_xml_text(item, "span.item-price").to_int_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, "span.size"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "#description > p > span:nth-child(3)").strip
          details = access_xml_text(html, '.detail-list').strip.gsub(/[^[:print:]]/, "").strip.gsub(/[^[:print:]]/, "").gsub(' ','')
          hashed_property[:floor] = regex_gen(details, 'Etage:(\d)*').to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(details, 'Chambres:(\d)*').to_int_scrp
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
                    hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(item, '.prop-user-agent')
          hashed_property[:images] = access_xml_link(html, 'div.item > a > img' ,'src')
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
