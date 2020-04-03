class SmallSites::ScraperJunot < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.junot.fr/fr/resultat?type=buy&location[]=75001&location[]=75002&location[]=75003&location[]=75004&location[]=75005&location[]=75006&location[]=75007&location[]=75008&location[]=75009&location[]=75010&location[]=75011&location[]=75012&location[]=75013&location[]=75014&location[]=75015&location[]=75016&location[]=75116&location[]=75017&location[]=75018&location[]=75019&location[]=75020"
    @source = "Junot"
    @main_page_cls = "li.block_product"
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
        hashed_property[:link] = access_xml_link(item, "a.title-article", "href")[0].to_s
        hashed_property[:area] = regex_gen(access_xml_text(item, "a.title-article > span:nth-child(1)").downcase, 'paris(\s)(\d)*e').to_int_scrp.to_s.district_generator
        hashed_property[:rooms_number] = access_xml_text(item, 'span[itemprop="numberOfRooms"]').to_int_scrp
        hashed_property[:surface] = access_xml_text(item, 'span[itemprop="floorSize"]').to_float_to_int_scrp
        hashed_property[:price] = access_xml_text(item, ".price> span:nth-child(1) > span:nth-child(1)").gsub(" ", "").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, ".description").strip
          details = access_xml_text(item, ".right-block-top-right").strip.gsub(" ", "").gsub(/[^[:print:]]/, "").downcase
          hashed_property[:bedrooms_number] = regex_gen(details, 'chambre(s)+:(\d)*').to_int_scrp if details.match(/chambre(s)+:(\d)*/i).is_a?(MatchData)
          details.match(/ascenseur:oui/i).is_a?(MatchData) ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, ".appartement"))
          floor = regex_gen(access_xml_text(html, 'li[itemprop="floorLevel"]').gsub(" ", ""), '(\d*)/')
          floor.empty? ? hashed_property[:floor] = nil : hashed_property[:floor] = floor.to_int_scrp
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "ul.slideshow > li > img", "src")
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
