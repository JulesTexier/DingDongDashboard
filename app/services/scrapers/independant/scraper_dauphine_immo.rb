class Independant::ScraperDauphineImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Dauphine Immo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a:nth-child(1)", "href")[0].to_s
          title = access_xml_text(item, ".property-title")
          hashed_property[:area] = perform_district_regex(title.gsub(/[^0-9A-Za-z]/, " "))
          hashed_property[:flat_type] = get_type_flat(title)
          if hashed_property[:flat_type] == "Studio"
            hashed_property[:rooms_number] = 1
            hashed_property[:bedrooms_number] = 1
          else
            hashed_property[:rooms_number] = regex_gen(title.gsub(" ", ""), '(\d){1,}pi').to_int_scrp
          end
          hashed_property[:price] = access_xml_text(item, "span.item-price").to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "span.size"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#description > p > span:nth-child(3)").strip
            details = access_xml_text(html, ".detail-list").strip.gsub(/[^[:print:]]/, "").strip.gsub(/[^[:print:]]/, "").gsub(" ", "")
            hashed_property[:floor] = regex_gen(details, 'Etage:(\d)*').to_int_scrp
            hashed_property[:bedrooms_number] = regex_gen(details, 'Chambres:(\d)*').to_int_scrp if hashed_property[:bedrooms_number].nil?
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:agency_name] = access_xml_text(item, ".prop-user-agent")
            hashed_property[:images] = access_xml_link(html, "div.item > a > img", "src")
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
