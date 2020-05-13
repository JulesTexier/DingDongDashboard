class Premium::ScraperMeilleursAgents < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "MeilleursAgents"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      html = fetch_static_page_proxy(args.url)
      xml = access_xml_raw(html, args.main_page_cls)
      # if !xml[0].to_s.strip.empty?
        hashed_properties = []
        xml.each do |item|
          begin
            hashed_property = extract_each_flat(item)
            property_checker_hash = {}
            property_checker_hash[:rooms_number] = hashed_property[:rooms_number]
            property_checker_hash[:surface] = hashed_property[:surface]
            property_checker_hash[:price] = hashed_property[:price]
            property_checker_hash[:area] = hashed_property[:area]
            property_checker_hash[:link] = hashed_property[:link]
            if go_to_prop?(property_checker_hash, 60)
              @properties.push(hashed_property)
              enrich_then_insert_v2(hashed_property)
              i += 1
            end
            break if i == limit
          rescue StandardError => e
            error_outputs(e, @source)
            next
          end
        end
      # else
      #   puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
      # end
    end
    return @properties
  end

  private

  def extract_each_flat(item)
    hashed_property = {}
    hashed_property[:link] = access_xml_link(item, "a.listing-item__picture-container", "href")[0].to_s
    hashed_property[:images] = ["https:" + access_xml_link(item, "img.listing-item__picture", "src")[0].to_s]
    hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.text--muted.text--small"))
    hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
    hashed_property[:surface] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
    hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '\d(.)*(pi(è|e)ce(s?))').to_float_to_int_scrp
    hashed_property[:rooms_number] = 1 if hashed_property[:flat_type] == "Studio"
    hashed_property[:price] = access_xml_text(item, "div.listing-price.margin-bottom").to_int_scrp
    hashed_property[:has_elevator] = nil
    hashed_property[:floor] = nil
    hashed_property[:source] = @source
    hashed_property[:provider] = "Agence"
    hashed_property[:description] = ""
    puts JSON.pretty_generate(hashed_property)
    return hashed_property
  end
end
