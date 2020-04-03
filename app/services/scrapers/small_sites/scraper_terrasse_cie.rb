class SmallSites::ScraperTerrasseCie < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "http://www.terrasse-cie.com/fr/ventes?order=news%7Cdesc"
    @source = "TerrasseCie"
    @main_page_cls = ".ad"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "http://www.terrasse-cie.com" + access_xml_link(item, "a.button", "href")[1].to_s
        hashed_property[:area] = access_xml_text(item, "h2").area_translator_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, "li.area"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "li.price > div"), '(\d)(.*)').to_int_scrp != 0 ? regex_gen(access_xml_text(item, "li.price > div"), '(\d)(.*)').to_int_scrp : nil
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(html, ".summary > ul"), '(\d+)(.?)(PI(È|e)CE(S?))').to_float_to_int_scrp
          hashed_property[:description] = access_xml_text(html, "p.comment").strip
          hashed_property[:agency_name] = "Terrasse Cie"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".slideshow > img", "src")
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
