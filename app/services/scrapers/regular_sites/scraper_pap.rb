class RegularSites::ScraperPap < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.pap.fr/annonce/vente-appartement-maison-paris-75-g439-a-partir-du-studio"
    @source = "PAP"
    @main_page_cls = "div.search-list-item"
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
        hashed_property[:link] = "https://www.pap.fr" + access_xml_link_matchdata(item, "div.col-right > a", "href", "(#dialog_mensualite|www.immoneuf.com/)")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.col-right > a.item-title > ul").specific_trim_scrp("\n\r\t"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.col-right > p.item-description"))
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.col-right > a.item-title > ul"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.col-right > a.item-title > span.item-price"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.item-tags.margin-bottom-20").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "div.item-description").specific_trim_scrp("\n\t\r").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "h1.item-title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Particulier"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.owl-thumbs.sm-hidden img", "src")
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
