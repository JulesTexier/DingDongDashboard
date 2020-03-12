class ScraperCentury < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.century21.fr/annonces/achat-maison-appartement/v-paris/s-0-/st-0-/b-0-/tri-date-desc/page-1/"
    @source = "Century21"
    @xml_first_page = "div.contentAnnonce"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.century21.fr" + access_xml_link(item, "div.zone-text-loupe a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h4.detail_vignette"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.zone-text-loupe > a > h3"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4.detail_vignette"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.price"), '(\d)(.*)(€)').to_int_scrp
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    enrich_then_insert(hashed_properties)
  end

  private

  def extract_each_flat(prop)
    flat_data = {}
    html = fetch_static_page(prop[:link])
    flat_data[:link] = prop[:link]
    flat_data[:surface] = prop[:surface]
    flat_data[:area] = prop[:area]
    flat_data[:rooms_number] = prop[:rooms_number]
    flat_data[:price] = prop[:price]
    flat_data[:description] = access_xml_text(html, "#focusAnnonceV2 > section.precision > div.desc-fr > p").specific_trim_scrp("\n").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "div.content > div > h1"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
    flat_data[:agency_name] = access_xml_text(html, "span.agency-name")
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link_matchdata_src(html, "a.fancybox", "href", "(#popupReseauxSociauxAG)", "https://www.century21.fr")
    return flat_data
  end
end
