class Independant::ScraperAgenceTroisFreres < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Agences des 3 Frères"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "h3 > a", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "span.property-box-meta-item-area").to_float_to_int_scrp
          hashed_property[:rooms_number] = access_xml_text(item, "span.property-box-meta-item-beds:nth-child(3)").to_int_scrp
          item.css("span.property-box-meta-item-beds").each do |room|
            hashed_property[:rooms_number] = room.text.to_int_scrp if room.at("i").attributes["class"].value.include?("pp-normal-door-in")
          end
          hashed_property[:price] = access_xml_text(item, "div.property-box-image-price").to_int_scrp
          hashed_property[:flat_type] = 'N/C'
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.property-description > p").tr("\n\t\r", "").strip
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.property-overview").split("Localisation")[1])
            next if hashed_property[:area] == "N/C"
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33663036454"
            hashed_property[:source] = @source
            access_xml_raw(html, "div.property-detail-gallery-preview").each do |imgs|
              hashed_property[:images] = access_xml_link(imgs, "img", "src").map { |img| img.gsub("150x150", "300x300") }
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
