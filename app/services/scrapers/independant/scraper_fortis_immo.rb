class Independant::ScraperFortisImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Fortis Immo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      json = Nokogiri::HTML.parse(fetch_main_page(args)["purchases"])
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
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.carousel-item", "style").map { |img| img.split("url('")[1].split("')")[0] }
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        end
      end
    rescue StandardError => e
      error_outputs(e, @source)
      next
    end
    return @properties
  end
end
