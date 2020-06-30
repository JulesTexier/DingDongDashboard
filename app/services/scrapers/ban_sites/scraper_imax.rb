class BanSites::ScraperImax < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.imax.fr/recherche,basic.htm?tri=d_px&idtt=2#ci=750109,750109,750116,750116,750117,750117,750118,750118&idqfix=1&idtt=2&idtypebien=1,2&lang=fr&pres=prestige&pxmax=Max&pxmin=Min&surf_terrainmax=Max&surf_terrainmin=Min"
    @source = "Imax"
    @main_page_cls = "div.recherche-annonces-vente"
    @scraper_type = "Dynamic"
    @waiting_cls = "recherche-annonces-vente"
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 5
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "div.span8 > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.margin-bottom-10.padding-bottom-10.border-solid-bottom-block-1.pagination-centered > p"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.small.pagination-centered > p"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.margin-bottom-10.padding-bottom-10.border-solid-bottom-block-1.pagination-centered").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.typo-action.h2-like.prix-annonce.pagination-centered").to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "span.typo-action"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.bloc-detail-descriptif").specific_trim_scrp("\n").strip
          hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.nivoSlider > a", "href")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert(hashed_property)
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
