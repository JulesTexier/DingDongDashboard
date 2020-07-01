class Group::ScraperSaintFerdinand < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Saint-Ferdinand"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a", "href")[0]
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.listing_details"))
          next if hashed_property[:area] == "N/C"
          hashed_property[:surface] = access_xml_text(item, "span.infosize").tr("m2", "").to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_text(item, "span.inforoom").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#description").strip
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "div.listing_detail").remove_acc_scrp, '(pieces:)(.?)(\d+)').to_int_scrp
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            imgs = access_xml_link(html, '[itemprop="image"]', "src")
            hashed_property[:images] = access_xml_link(html, 'li[data-target="#carousel-listing"] > img', "src").map { |img| img.gsub("-143x83", "") }
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        rescue StandardError => e
          error_outputs(e, @source)
          next
        end
      end
    end
    return @properties
  end
end
