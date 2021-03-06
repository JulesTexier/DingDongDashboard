class Independant::ScraperKrystynaImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Krystyna"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = "https://www.krystyna-immobilier.com" + access_xml_link(item, "> a", "href")[0].to_s.gsub("..", "")
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.products-name"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.products-localisation"))
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.products-name").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.products-price"), '(\d+)(.)(\d+)(.)(\d+)(...)(dont)').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.products-name"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.product-description").specific_trim_scrp("\n").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.item-slider > a", "href")
            hashed_property[:images].collect! { |img| "https://www.krystyna-immobilier.com" + img.gsub("..", "") }
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
