class ScraperGuyHoquet < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.guy-hoquet.com/biens/result#1&p=1&t=3&f10=1&f20=75_c2&f30=appartement,maison"
    @source = "Guy Hoquet"
    @main_page_cls = "div.resultat-item"
    @type = "Dynamic"
    @waiting_cls = ["launcher-icon", "animate"]
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 3
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a.property_link_block", "href")[0].to_s
        hashed_property[:rooms_number] = access_xml_text(item, "div.actions > span:nth-child(1)").to_float_to_int_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.actions > span:nth-child(2)"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.price"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:area] = perform_district_regex(html.text)
          hashed_property[:description] = access_xml_text(html, "span.description-more").strip
          hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "h1"))
          hashed_property[:agency_name] = "Guy Hoquet"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".de-biens-slider-itm", "href")
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
