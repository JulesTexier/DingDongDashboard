class Group::ScraperKellerWilliams < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Keller Williams"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.kwfrance.com/" + item["href"].gsub("../", "")
          hashed_property[:surface] = access_xml_text(item, "span.number").split(" ")[0].to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "span.prix").split("\u0080")[0].to_int_scrp
          hashed_property[:rooms_number] = access_xml_text(item, "span.number").split(" ")[1].to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_text(item, "span.number").split(" ")[2].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_array_to_text(html, "#accordion").split("Code postal")[1].split("Ville")[0])
            hashed_property[:description] = access_xml_text(html, "p.description").strip
            hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.link_img_bien", "href").map { |img| "https://www.kwfrance.com/" + img.gsub!("../", "") }
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
