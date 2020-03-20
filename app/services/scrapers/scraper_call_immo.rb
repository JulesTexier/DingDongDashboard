class ScraperCallImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.callimmo.fr/fr/vente/1/?o=d_mandate,desc"
    @source = "Callimmo"
    @main_page_cls = "article.ui-property"
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
        hashed_property[:link] = "http://www.callimmo.fr" + access_xml_link(item, "div.overlay-container > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "ul.inline-list"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = access_xml_text(item, "div.vertical-align > h2").area_translator_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.vertical-align > h2").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.vertical-align > h3"), '(\d)(.*)(€)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.vertical-align > h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if is_property_clean(hashed_property)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.read-more").specific_trim_scrp("\n").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = ["http://www.callimmo.fr" + access_xml_link(html, "li.clearing-featured-img.small-12.margin-no > div > a", "href")[0].to_s]
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
