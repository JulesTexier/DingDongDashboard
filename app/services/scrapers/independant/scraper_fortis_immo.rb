class Independant::ScraperFortisImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_request, :http_type

  def initialize
    @url = "https://www.fortisimmo.fr/wp-admin/admin-ajax.php"
    @source = "Fortis Immo"
    @main_page_cls = "div.purchase-wrapper"
    @scraper_type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @wait = 0
    @page_nbr = 3
    @properties = []
    @http_request = [{}, "action=get_properies&data%5Bprice_leasings%5D=0%2C10000&data%5Btype%5D%5B%5D=purchases&data%5Bprice_purchases%5D=0%2C2000000&data%5Btypes%5D%5B%5D=Appartement&data%5Btypes%5D%5B%5D=Maison&data%5Bpieces%5D%5B%5D=1&data%5Bpieces%5D%5B%5D=2&data%5Bpieces%5D%5B%5D=3&data%5Bpieces%5D%5B%5D=4&data%5Bpieces%5D%5B%5D=5&data%5Bpieces%5D%5B%5D=6&data%5Bsurface%5D=0%2C600"]
    @http_type = "post_json"
  end

  def launch(limit = nil)
    i = 0
    json = Nokogiri::HTML.parse(fetch_main_page(self)["purchases"])
    access_xml_raw(json, "div.purchase-wrapper").each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "div.more > a.btn-outline", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "li.list-group-item").tr("\n", ""), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_array_to_text(item, "li.list-group-item"))
        hashed_property[:area] = nil if hashed_property[:area] == "N/C"
        hashed_property[:price] = regex_gen(access_xml_array_to_text(item, "li.list-group-item").gsub(" ", ""), '(\d*)(.?)(€)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "span.title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "li.list-group-item").remove_acc_scrp, '(\d+)(.?)(piece)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.description > p").strip
          hashed_property[:area] = perform_district_regex(hashed_property[:description]) if hashed_property[:area].nil?
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.carousel-item", "style").map { |img| img.split("url('")[1].split("')")[0] }
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      end
    rescue StandardError => e
      error_outputs(e, @source)
      next
    end
    return @properties
  end
end
