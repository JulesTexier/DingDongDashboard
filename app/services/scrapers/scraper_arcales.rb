class ScraperArcales < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "http://www.arcales.fr/recherche/[[PAGE_NUMBER]]"
    @source = "Arcales"
    @main_page_cls = ".panelBien"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = true
    @wait = 0
    @page_nbr = 3
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "http://www.arcales.fr" + access_xml_link(item, "h1 > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2"))
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.col-xs-12.col-sm-5.panel-heading > ul > li:nth-child(2) > span:nth-child(2) > span:nth-child(1)"), '(\d)(.*)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.mainContent > div:nth-child(2) > div:nth-child(1) > p").strip
          hashed_property[:agency_name] = "Arcales"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "ul > li > img", "src")
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
