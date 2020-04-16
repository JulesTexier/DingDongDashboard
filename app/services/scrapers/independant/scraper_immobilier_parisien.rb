class Independant::ScraperImmobilierParisien < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "http://www.immobilier-parisien.fr/index.php?contr=biens_liste&tri_lots=date&type_transaction=0&type_lot%5B%5D=appartement&localisation=Paris+-+75&hidden-localisation=Paris+-+75&nb_piece=&surface=&budget_min=&budget_max=&page=0&vendus=0&submit_search_0="
    @source = "Immobilier Parisien"
    @main_page_cls = ".properties-grid > div > div.col-sm-6"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @wait = 0
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "div.ContourBiensListe > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "p.text-right"), '(\d)(.*)').to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4 > a"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.localisation"))
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.content > p").tr("\n\r\t", "").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h4 > a"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.carousel-inner > div > a > img", "src").map { |img| "http://www.immobilier-parisien.fr" + img }
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
