class ScraperOrpi < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.orpi.com/recherche/buy?transaction=buy&resultUrl=&realEstateTypes%5B0%5D=maison&realEstateTypes%5B1%5D=appartement&locations%5B0%5D%5Bvalue%5D=paris&locations%5B0%5D%5Blabel%5D=Paris&agency=&minSurface=10&maxSurface=400&nbRooms%5B0%5D=1&nbRooms%5B1%5D=2&nbRooms%5B2%5D=3&nbRooms%5B3%5D=4&nbRooms%5B4%5D=5&nbRooms%5B5%5D=6&newBuild=true&oldBuild=true&minPrice=100000&maxPrice=6000000&sort=date-down&layoutType=list&nbBedrooms=&page=&minLotSurface=&maxLotSurface=&minStoryLocation=&maxStoryLocation="
    @source = "Orpi"
    @xml_first_page = "div.c-box__inner.c-box__inner--sm"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page, "Dynamic", "o-grid")
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.orpi.com" + access_xml_link(item, "a.u-link-unstyled.c-overlay__link", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "a.u-link-unstyled.c-overlay__link").specific_trim_scrp("\n\r\t"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = "750" + access_xml_text(item, "p.u-mt-sm").tr("^0-9", "")
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "a.u-link-unstyled.c-overlay__link"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div:nth-child(1) > div:nth-child(2)"), '(\d)(.*)(€)').to_int_scrp
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
    flat_data[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "div#collapse-details-panel").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "div.o-container > p:nth-child(2)").specific_trim_scrp("\n\r").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "span.u-text-xl"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Particulier"
    flat_data[:source] = @source
    flat_data[:images] = []
    html.css("img.u-cover.u-flex-item-auto").each do |img|
      chr_array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
      html.css("a.c-btn.c-btn--tertiary").each do |nbr_item|
        nbr = nbr_item.text.gsub("Voir les ", "").gsub("photos", "").to_i
        i = 0
        nbr.times do
          new_img = img[:src].gsub("a--", chr_array[i] + "--")
          flat_data[:images].push(new_img)
          i += 1
        end
      end
    end
    return flat_data
  end
end
