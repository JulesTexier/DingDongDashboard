class Independant::ScraperLuxResidence < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Lux Residence"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a", "href")[2].to_s
          hashed_property[:price] = regex_gen(access_xml_text(item, ".price"), '(\d)(.*)').to_int_scrp
          sub_item = access_xml_array_to_text(item, "div.prod-r.prod-desc")
          hashed_property[:area] = perform_district_regex(sub_item)
          hashed_property[:surface] = regex_gen(sub_item, '(\d+(.?)(\d*))(.)(m2)').to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(sub_item.remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(access_xml_raw(item, 'img[itemprop="image"]')[0].attributes["alt"].text, '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:rooms_number] = hashed_property[:bedrooms_number] + 1 if hashed_property[:rooms_number].nil? && !hashed_property[:bedrooms_number].nil?
          hashed_property[:flat_type] = get_type_flat(sub_item)
          if go_to_prop?(hashed_property, 7) # Just to check but I don't load HTML show
            hashed_property[:description] = access_xml_text(item, "p.description").strip
            hashed_property[:agency_name] = access_xml_text(item, "h4").gsub("Agence : ", "")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(item, "img", "src")
            hashed_property[:images].delete_if { |img| img == nil }
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
