class Independant::ScraperBonjourOscar < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.bonjour-oscar.com/acheter/"
    @source = "Bonjour Oscar"
    @main_page_cls = "li.listGoods-item"
    @scraper_type = "Static"
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
        hashed_property[:link] = access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.listGoods-zip"))
        hashed_property[:price] = regex_gen(access_xml_text(item, "span.listGoods-price"), '(\d)(.*)').to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.listGoods-infoBarRight > span:nth-child(1)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:surface] = access_xml_text(html, "li.spaces-item:nth-child(1) > span:nth-child(2)").to_float_to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_text(html, "li.spaces-item:nth-child(2) > span:nth-child(2)").to_int_scrp
          hashed_property[:description] = access_xml_text(html, ".description-content").strip
          hashed_property[:floor] = access_xml_text(html, "li.spaces-item:nth-child(4) > span:nth-child(2)").to_int_scrp
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = @source + " - " + access_xml_text(html, ".agencyTeaser-title")
          hashed_property[:contact_number] = access_xml_text(html, ".agencyTeaser-phone").gsub(" ", "").convert_phone_nbr_scrp
          hashed_property[:images] = access_xml_link(html, "img.sliderGood-image", "src")
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
