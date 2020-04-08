class Independant::ScraperEngelVoelkers < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.engelvoelkers.com/fr/search/?q=&startIndex=0&businessArea=residential&sortOrder=DESC&sortField=newestProfileCreationTimestamp&pageSize=18&facets=bsnssr%3Aresidential%3Bcntry%3Afrance%3Bdstrct%3Aparis%3Brgn%3Aile_de_france%3Btyp%3Abuy%3B"
    @source = "Engel Voelkers"
    @main_page_cls = "div.col-lg-4"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @wait = 0
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.ev-teaser-attributes > div:last-child"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.ev-value"), '(\d)(.*)').to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, ".ev-teaser-subtitle"))
        next if hashed_property[:area] == "N/C"
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(html, "ul.ev-exposee-detail-facts"), 'Pi(e|è)ce(s?)(.?)(\d+)').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "p.ev-exposee-text").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, ".ev-exposee-subtitle"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:agency_name] = "Engel Voelkers"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "img.ev-image-gallery-image", "src")
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
