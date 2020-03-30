class ScraperOrpi < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.orpi.com/recherche/buy?transaction=buy&resultUrl=&realEstateTypes%5B0%5D=maison&realEstateTypes%5B1%5D=appartement&locations%5B0%5D%5Bvalue%5D=paris&locations%5B0%5D%5Blabel%5D=Paris&agency=&minSurface=10&maxSurface=400&nbRooms%5B0%5D=1&nbRooms%5B1%5D=2&nbRooms%5B2%5D=3&nbRooms%5B3%5D=4&nbRooms%5B4%5D=5&nbRooms%5B5%5D=6&newBuild=true&oldBuild=true&minPrice=100000&maxPrice=6000000&sort=date-down&layoutType=list&nbBedrooms=&page=&minLotSurface=&maxLotSurface=&minStoryLocation=&maxStoryLocation="
    @source = "Orpi"
    @main_page_cls = "div.c-box__inner.c-box__inner--sm"
    @type = "Dynamic"
    @waiting_cls = "u-mt-md"
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 0
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.orpi.com" + access_xml_link(item, "a.u-link-unstyled.c-overlay__link", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "a.u-link-unstyled.c-overlay__link").specific_trim_scrp("\n\r\t"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = "750" + access_xml_text(item, "p.u-mt-sm").tr("^0-9", "")
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "a.u-link-unstyled.c-overlay__link"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div:nth-child(1) > div:nth-child(2)"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "div#collapse-details-panel").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "div.o-container > p:nth-child(2)").specific_trim_scrp("\n\r").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "span.u-text-xl"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Particulier"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          html.css("img.u-cover.u-flex-item-auto").each do |img|
            chr_array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
            html.css("a.c-btn.c-btn--tertiary").each do |nbr_item|
              nbr = nbr_item.text.gsub("Voir les ", "").gsub("photos", "").to_i
              j = 0
              nbr.times do
                new_img = img[:src].gsub("a--", chr_array[j] + "--")
                hashed_property[:images].push(new_img)
                j += 1
              end
            end
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
