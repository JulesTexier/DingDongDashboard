class Independant::ScraperDavidMatton < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "David Matton"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.davidmattonimmobilier.com/" + access_xml_link(item, ".titreBien", "href")[0].to_s.gsub("../", "")
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".carac"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(item.text)
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".carac"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          price_item = access_xml_text(item, ".carac > div:nth-child(3)")
          price_item.include?("dont") ? hashed_property[:price] = regex_gen(price_item, '(\d)(.*)(dont)').to_int_scrp : hashed_property[:price] = price_item.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            detail = access_xml_text(html, "#detailCarac")
            hashed_property[:description] = access_xml_text(html, ".description").strip
            hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp if regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp != 0
            hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
            hashed_property[:agency_name] = @source
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.img", "style").map { |img| "http://www.davidmattonimmobilier.com" + img.split("url('")[1].split("')")[0][2..-1] }
            hashed_property[:images].delete("http://www.davidmattonimmobilier.com/office8/david_matton_immobilier/catalog/images/background.jpg")
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
