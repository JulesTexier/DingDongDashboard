class Independant::ScraperLoretoImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.loretoimmobilier.com/fr/vente-studio-maison-appartement-hotel-particulier-loft-atelier-paris/tri=id&ordre=DESC"
    @source = "Loreto Immo"
    @main_page_cls = "div.annonce_listing"
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
        hashed_property[:link] = "https://www.loretoimmobilier.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".info > span:nth-child(1)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "span.always > p:nth-child(2) > span:nth-child(1)"), '(\d)(.*)(€)').to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".info > span:nth-child(2)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.always > p:nth-child(1) > span:nth-child(1)"))
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, ".detail_description").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "p.type"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:agency_name] = "Loreto Immo"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          access_xml_array_to_text(html, "script").each_line do |line|
            hashed_property[:images].push("https://www.loretoimmobilier.com" + line.split('src:"')[1].split('", title:')[0]) if line.include?('items.push({ src:"/datas/biens')
          end
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
