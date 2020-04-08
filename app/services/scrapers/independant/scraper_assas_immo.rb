class Independant::ScraperAssasImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.assasimmobilier.com/vente-loft-hotel-particulier-appartement-paris-assas-immobilier/"
    @source = "Assas Immo"
    @main_page_cls = "div.annonce_listing"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 1
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.assasimmobilier.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(3)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:price] = access_xml_text(item, "a > figure > figcaption > p:nth-child(2) > span").tr("^0-9", "").to_int_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(2)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(1)"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        hashed_property[:area] = perform_district_regex(hashed_property[:link])
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.descriptif").strip
          hashed_property[:agency_name] = "Assas Immobilier"
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          access_xml_text(html, "section#annonce_profil").each_line do |line|
            hashed_property[:images].push("https://www.assasimmobilier.com" + line.split("src:'")[1].split("', title:")[0]) if line if line.include?("items.push({ src:'/datas/biens")
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
