class Independant::ScraperEfficity < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Efficity"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.efficity.com" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.location.text-truncate"))
          hashed_property[:price] = regex_gen(access_xml_text(item, "p.price"), '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "h1.program-details-title"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
            hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, "ul.program-details-features > li"), '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "#default-presentation").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "h1.program-details-title"))
            hashed_property[:agency_name] = "Efficity"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            img_array = access_xml_link(html, ".img-fluid", "src").map { |img| "https:" + img }
            img_array.each do |img| 
              break if img.include?("illustration.png")
              hashed_property[:images].push(img)
            end
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
