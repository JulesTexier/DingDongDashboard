class ScraperLogicImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.logic-immo.com/vente-immobilier-paris-75,100_1/options/groupprptypesids=1,2,6,7,12,15/order=update_date_desc"
    @source = "LogicImmo"
    @main_page_cls = "div.offer-details-wrapper"
    @type = "Static"
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
        hashed_property[:link] = access_xml_link_matchdata(item, "div.offer-details-location > a", "href", "https://www.lux-residence.com/")[0].to_s
        hashed_property[:surface] = access_xml_text(item, " div.offer-details-caracteristik > a > span.offer-details-caracteristik--area > span").to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.offer-details-location"), '(75)$*\d+{3}')
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
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
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
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
