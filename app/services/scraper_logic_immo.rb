class ScraperLogicImmo < Scraper

    attr_accessor :url, :properties, :source, :xml_first_page
  
    def initialize
      @url = 'https://www.logic-immo.com/vente-immobilier-paris-75,100_1/options/groupprptypesids=1,2,6,7,12,15/order=update_date_desc'
      @source = 'LogicImmo'
      @xml_first_page = 'div.offer-details-wrapper'
    end
  
    def extract_first_page
      xml = fetch_first_page(@url, @xml_first_page)
      hashed_properties = []
      xml.each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link_matchdata(item, 'div.offer-details-location > a', 'href', 'https://www.lux-residence.com/')[0].to_s
          hashed_property[:surface] = access_xml_text(item, ' div.offer-details-caracteristik > a > span.offer-details-caracteristik--area > span').to_int_scrp
          hashed_property[:area] = regex_gen(access_xml_text(item, 'div.offer-details-location'), '(75)$*\d+{3}')
          hashed_property[:rooms_number] = access_xml_text(item, 'div.offer-details-caracteristik > a > span.offer-details-caracteristik--rooms > span').to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, 'div.offer-details-price > p.offer-price > span'), '(\d)(.*)(€)').to_int_scrp
          hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
        rescue StandardError => e 
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
      enrich_then_insert(hashed_properties)
    end
  
    private
  
    def extract_each_flat(prop)
      flat_data = {}
      html = fetch_static_page(prop[:link])
      flat_data[:link] = prop[:link]
      flat_data[:surface] = prop[:surface]
      flat_data[:area] = prop[:area]
      flat_data[:rooms_number] = prop[:rooms_number]
      flat_data[:price] = prop[:price]
      flat_data[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, 'ul.unstyled.flex').specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
      flat_data[:description] = access_xml_text(html, 'div.offer-description-text').specific_trim_scrp("\n").gsub('Être rappelé', '').gsub('Demander une visite', '').gsub("Obtenir l'adresse", '').strip
      flat_data[:flat_type] = access_xml_text(html, '#js-faToaster > div > div.leftZone.clearfix > div.cell.type').specific_trim_scrp("\n\s")
      flat_data[:agency_name] = access_xml_text(html, 'span.agency-name')
      flat_data[:floor] = perform_floor_regex(flat_data[:description])
      flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
      flat_data[:provider] = 'Agence'
      flat_data[:source] = @source
  
      flat_data[:images] = []
      html.css('#offer_pictures_main').each do |img_urls|
        img_urls.attr('src').each_line do |img_url|
          flat_data[:images].push(img_url)
        end
      end
      html.css('#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(1) > a > img').each do |img_thumb|
        flat_data[:images].push(img_thumb['src'].gsub('photo-prop-182x136', 'photo-prop-800x600'))
      end
      html.css('#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(2) > a > img').each do |img_thumb|
        flat_data[:images].push(img_thumb['src'].gsub('photo-prop-182x136', 'photo-prop-800x600'))
      end
      html.css('#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(3) > a > img').each do |img_thumb|
        flat_data[:images].push(img_thumb['src'].gsub('photo-prop-182x136', 'photo-prop-800x600'))
      end
      html.css('#gallery > div:nth-child(2) > div > div > div > div > div.minThumbs > ul > li:nth-child(4) > a > img').each do |img_thumb|
        flat_data[:images].push(img_thumb['src'].gsub('photo-prop-182x136', 'photo-prop-800x600'))
      end
      return flat_data
    end
  end 