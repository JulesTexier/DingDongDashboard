class Independant::ScraperTendancesImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.tendancesimmobilieres.com/properties/?filter_location=74&filter_type=25&filter_contract_type=21&filter_price_from=&filter_price_to=&filter_area_from=&filter_area_to=&filter_sort_by=date&filter_order=DESC"
    @source = "Tendances Immobilières"
    @main_page_cls = "div.property"
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
        price = access_xml_text(item, '.price').gsub(/[^[:print:]]/, "")
        next if price.downcase.include?("vendu")
        hashed_property[:link] = access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".area"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, ".location"))
        hashed_property[:flat_type] = get_type_flat(access_xml_text(item, '.body'))
        if hashed_property[:surface] < 25 || hashed_property[:flat_type] == "Studio"
          hashed_property[:rooms_number] = 1
          hashed_property[:bedrooms_number] = 0
        else
          hashed_property[:bedrooms_number] = access_xml_text(item, ".bedrooms").to_int_scrp
          hashed_property[:rooms_number] = hashed_property[:bedrooms_number] + 1
        end
        hashed_property[:price] = price.strip.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, '.property-detail> p').strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
          hashed_property[:provider] = "Agence"
          hashed_property[:agency_name] = @source
          hashed_property[:contact_number] = "0155323232"
          hashed_property[:source] = @source
          hashed_property[:images] =  access_xml_link(html, '.gallery> img', 'src')
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
