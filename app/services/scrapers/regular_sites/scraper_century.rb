class RegularSites::ScraperCentury < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.century21.fr/annonces/achat-maison-appartement/v-paris/s-0-/st-0-/b-0-/tri-date-desc/page-1/"
    @source = "Century21"
    @main_page_cls = "div.contentAnnonce"
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
        hashed_property[:link] = "https://www.century21.fr" + access_xml_link(item, "div.zone-text-loupe a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h4.detail_vignette"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.zone-text-loupe > a > h3"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4.detail_vignette"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.price"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "#focusAnnonceV2 > section.precision > div.desc-fr > p").specific_trim_scrp("\n").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "div.content > div > h1"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link_matchdata_src(html, "a.fancybox", "href", "(#popupReseauxSociauxAG)", "https://www.century21.fr")
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
