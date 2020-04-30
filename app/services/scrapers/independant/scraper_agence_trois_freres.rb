class Independant::ScraperAgenceTroisFreres < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://agencedes3freres.com/?page_id=1213"
    @source = "Agences des 3 Frères"
    @main_page_cls = "div.property-container"
    @scraper_type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "h3 > a", "href")[0]
        hashed_property[:surface] = access_xml_text(item, "span.property-box-meta-item-area").to_float_to_int_scrp
        hashed_property[:rooms_number] = access_xml_text(item, "span.property-box-meta-item-beds:nth-child(3)").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.property-box-image-price").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.property-description > p").tr("\n\t\r", "").strip
          hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.property-overview").split("Localisation")[1])
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33663036454"
          hashed_property[:source] = @source
          access_xml_raw(html, "div.property-detail-gallery-preview").each do |imgs|
            hashed_property[:images] = access_xml_link(imgs, "img", "src").map { |img| img.gsub("150x150", "300x300") }
          end
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
