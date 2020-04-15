require "typhoeus"

class Independant::ScraperRennesStGermain < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.rennes-st-germain.com/recherche/[[PAGE_NUMBER]]"
    @source = "Rennes Saint Germain"
    @main_page_cls = "article.panelBien"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = true
    @page_nbr = 2
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.rennes-st-germain.com" + access_xml_link(item, "div.caption-footer > a.btn-primary", "href")[0]
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(piece(s?))(.?)(\d+)').to_int_scrp
        hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(chambre\(s\))(.?)(\d+)').to_int_scrp
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(Surface)(.?)(\d+(.?)(\d*))(.?)(m)').tr("/[A-z]/", "").to_float_to_int_scrp
        byebug if hashed_property[:surface] == 0
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.ville"))
        hashed_property[:price] = access_xml_text(item, "div.left-caption").to_int_scrp
        hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.value > span"))
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "article.col-md-6.corp-elementDt6.elementDt > p").tr("\n", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33153630440"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "ul.imageGallery > li > img", "src").map { |img| "https:" + img }
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
