class Independant::ScraperGaranceImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "http://www.garance-immo.com/index.php?contr=biens_liste&tri_lots=date&type_transaction=0&type_lot%5B%5D=appartement&type_lot%5B%5D=maison&localisation=Paris+-+75&hidden-localisation=Paris+-+75&nb_piece=&surface=&budget_min=&budget_max=&page=0&vendus=0&submit_search_0="
    @source = "Garance Immobilier"
    @main_page_cls = "div.property"
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
        hashed_property[:link] = access_xml_link(item, "div.row > a", "href")[0]
        hashed_property[:surface] = access_xml_text(item, "span.icon_surface").gsub(/[[:space:]]/i, "").to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h4"))
        hashed_property[:rooms_number] = access_xml_text(item, "span.icon_pieces").gsub(/[[:space:]]/i, "").to_int_scrp
        hashed_property[:bedrooms_number] = access_xml_text(item, "span.icon_chambres").gsub(/[[:space:]]/i, "").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "h4:nth-child(20)").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.col-md-6.col-xs-12 > div:nth-child(2)").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:contact_number] = access_xml_text(html, "h4.panel-title > strong").gsub(".", "").convert_phone_nbr_scrp
          hashed_property[:images] = access_xml_link(html, "a.fancybox", "href").map { |img| "http://www.garance-immo.com" + img }
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
