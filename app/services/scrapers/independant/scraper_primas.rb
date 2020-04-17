class Independant::ScraperPrimas < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.primasimmobilier.com/vente-appartement-paris-75019/tri=id&ordre=DESC"
    @source = "Primas Immobilier"
    @main_page_cls = "article.annonce_listing"
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
        next if access_xml_text(item, "div.type").match(/(parking|commerce)/i).is_a?(MatchData)
        hashed_property = {}
        hashed_property[:link] = "https://www.primasimmobilier.com" + access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "p.infoSup").tr("\t\n", ""), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.address"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "p.infoSup").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.description").tr("\n\t\r", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33142087337"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "img.autoScale", "src").map { |img| "https://www.primasimmobilier.com" + img }
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