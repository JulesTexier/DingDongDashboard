class Independant::ScraperImmoLand < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.immo-land.fr/recherche/"
    @source = "Immo'Land"
    @main_page_cls = "li.panelBien"
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
        next if access_xml_text(item, "ul.list-inline").include?("Loyer")
        hashed_property = {}
        hashed_property[:link] = "http://www.immo-land.fr" + access_xml_link(item, "a.btn.btn-listing.pull-right", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.bienTitle"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.bienTitle"))
        next if hashed_property[:area] == "N/C"
        hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.bienTitle"))
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.bienTitle").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "ul.list-inline").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.mainContent > div:nth-child(2) > div:nth-child(1) > p").tr("\n\r\t", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:contact_number] = "+331 56 95 07 07"
          hashed_property[:images] = access_xml_link(html, "ul.imageGallery > li > img", "src")
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
