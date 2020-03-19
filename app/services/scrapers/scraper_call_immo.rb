class ScraperCallImmo < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "http://www.callimmo.fr/fr/vente/1/?o=d_mandate,desc"
    @source = "Callimmo"
    @xml_first_page = "article.ui-property"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "http://www.callimmo.fr" + access_xml_link(item, "div.overlay-container > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "ul.inline-list"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = access_xml_text(item, "div.vertical-align > h2").area_translator_scrp_bis
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.vertical-align > h2").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.vertical-align > h3"), '(\d)(.*)(€)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.vertical-align > h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
        # puts JSON.pretty_generate(hashed_properties)
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
    flat_data[:description] = access_xml_text(html, "p.read-more").specific_trim_scrp("\n").strip
    flat_data[:flat_type] = prop[:flat_type]
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] =  ["http://www.callimmo.fr" + access_xml_link(html, "li.clearing-featured-img.small-12.margin-no > div > a", "href")[0].to_s]
    # # puts JSON.pretty_generate(flat_data)
    return flat_data
  end
end
