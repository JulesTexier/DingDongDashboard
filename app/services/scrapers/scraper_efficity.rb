class ScraperEfficity < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.efficity.com/achat-immobilier/results/?inputed_location=8075056&property_type=1&max_price=&min_nb_of_rooms=1"
    @source = "Efficity"
    @main_page_cls = "div.annonce"
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
        hashed_property[:link] = "https://www.efficity.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "a > figcaption > h3 > span > span"))
        hashed_property[:price] = regex_gen(access_xml_text(item, "a > div > div > strong > span"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "#nom-bien"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, ".resume-picto"), '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "div.detail-desc-text").strip
          hashed_property[:flat_type] = access_xml_text(html, "#nom-bien").split("|")[0].tr(" ", "")
          hashed_property[:agency_name] = "Efficity"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".cbp-lightbox", "href")
          hashed_property[:images].collect! { |img| img.clean_img_link_https }
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
