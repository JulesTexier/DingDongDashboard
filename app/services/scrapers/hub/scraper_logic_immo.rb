class Hub::ScraperLogicImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "LogicImmo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link_matchdata(item, "div.offer-details-location > a", "href", "https://www.lux-residence.com/")[0].to_s
          next if hashed_property[:link].to_s.strip.empty?
          hashed_property[:surface] = access_xml_text(item, " div.offer-details-caracteristik > a > span.offer-details-caracteristik--area > span").to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.offer-details-location"), args.zone)
          hashed_property[:rooms_number] = access_xml_text(item, "div.offer-details-caracteristik > a > span.offer-details-caracteristik--rooms > span").to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.offer-details-price > p.offer-price > span"), '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.unstyled.flex").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "div.offer-description-text").specific_trim_scrp("\n").gsub("Être rappelé", "").gsub("Demander une visite", "").gsub("Obtenir l'adresse", "").strip
            hashed_property[:flat_type] = access_xml_text(html, "#js-faToaster > div > div.leftZone.clearfix > div.cell.type").specific_trim_scrp("\n\s")
            hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description], args.zone)
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = self.source
            hashed_property[:images] = []
            html.css("#offer_pictures_main").each do |img_urls|
              img_urls.attr("src").each_line do |img_url|
                hashed_property[:images].push(img_url)
              end
            end
            html.css("#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(1) > a > img").each do |img_thumb|
              hashed_property[:images].push(img_thumb["src"].gsub("photo-prop-182x136", "photo-prop-800x600"))
            end
            html.css("#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(2) > a > img").each do |img_thumb|
              hashed_property[:images].push(img_thumb["src"].gsub("photo-prop-182x136", "photo-prop-800x600"))
            end
            html.css("#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(3) > a > img").each do |img_thumb|
              hashed_property[:images].push(img_thumb["src"].gsub("photo-prop-182x136", "photo-prop-800x600"))
            end
            html.css("#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(4) > a > img").each do |img_thumb|
              hashed_property[:images].push(img_thumb["src"].gsub("photo-prop-182x136", "photo-prop-800x600"))
            end
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
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
