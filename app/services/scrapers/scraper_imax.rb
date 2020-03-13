class ScraperImax < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.imax.fr/recherche,basic.htm?tri=d_px&idtt=2#ci=750109,750109,750116,750116,750117,750117,750118,750118&idqfix=1&idtt=2&idtypebien=1,2&lang=fr&pres=prestige&pxmax=Max&pxmin=Min&surf_terrainmax=Max&surf_terrainmin=Min"
    @source = "Imax"
    @xml_first_page = "div.recherche-annonces-vente"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page, "Dynamic", "recherche-annonces-vente", 6)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "div.span8 > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.margin-bottom-10.padding-bottom-10.border-solid-bottom-block-1.pagination-centered > p"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.small.pagination-centered > p"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.margin-bottom-10.padding-bottom-10.border-solid-bottom-block-1.pagination-centered").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.typo-action.h2-like.prix-annonce.pagination-centered").to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "span.typo-action"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
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
    flat_data[:description] = access_xml_text(html, "p.bloc-detail-descriptif").specific_trim_scrp("\n").strip
    flat_data[:flat_type] = prop[:flat_type]
    flat_data[:agency_name] = access_xml_text(html, "span.agency-name")
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "div.nivoSlider > a", "href")
    return flat_data
  end
end
