class ScraperPap < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.pap.fr/annonce/vente-appartement-maison-paris-75-g439-a-partir-du-studio"
    @source = "PAP"
    @xml_first_page = "div.search-list-item"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.pap.fr" + access_xml_link_matchdata(item, "div.col-right > a", "href", "(#dialog_mensualite|www.immoneuf.com/)")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.col-right > a.item-title > ul").specific_trim_scrp("\n\r\t"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.col-right > p.item-description"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.col-right > a.item-title > ul"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "div.col-right > a.item-title > span.item-price"), '(\d)(.*)(€)').to_int_scrp
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
    flat_data[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.item-tags.margin-bottom-20").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "div.item-description").specific_trim_scrp("\n\t\r").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "h1.item-title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:provider] = "Particulier"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "div.owl-thumbs.sm-hidden img", "src")
    return flat_data
  end
end
