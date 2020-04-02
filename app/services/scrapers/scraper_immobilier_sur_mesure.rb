class ScraperImmobilierSurMesure < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args, :http_type, :http_request

  def initialize
    @url = "https://www.immobilier-surmesure.com/wp-admin/admin-ajax.php"
    @source = "Immo Sur Mesure"
    @main_page_cls = "div.mon-bien"
    @type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @properties = []
    @http_type = "post"
    @http_request = [{}, { "lieux[]": "paris-11", "lieux[]": "paris-12", "lieux[]": "paris-20", "Prix": "", "budget": "0,3000000", "surface-mini": "", "action": "myfilter", "cat": "14" }]
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "a > p:nth-child(3)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "a > p:nth-child(2)"), '(\d)(.*)').to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "a > p:nth-child(4)"), '(Pi(è|e)ce(s?) :)(.?)(\d+)').tr("^0-9", "").to_float_to_int_scrp
        hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '(\d+)(-?)(piece(s?))').to_int_scrp if hashed_property[:rooms_number] == 0
        hashed_property[:area] = regex_gen(access_xml_text(item, "a > h2"), '(\d+)').district_generator
        hashed_property[:area] = regex_gen(hashed_property[:link], '((paris)(-?)(\d+))').district_generator if hashed_property[:area] == "N/C"
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = regex_gen(access_xml_text(html, "div.infos-long > h2"), '(\d+)').district_generator if hashed_property[:area] == "N/C"
          hashed_property[:description] = access_xml_text(html, ".text-bien > p").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "strong.bread-current"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:agency_name] = "Immo Sur Mesure"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.single-bien-image > img", "src")
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
