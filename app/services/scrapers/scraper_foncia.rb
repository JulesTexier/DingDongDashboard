class ScraperFoncia < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://fr.foncia.com/achat/paris-75/appartement--maison/(params)/on/(tri)/date/(ordre)/desc"
    @source = "Foncia"
    @xml_first_page = "div.TeaserOffer-content"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://fr.foncia.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "div.MiniData-row"), '(\d+(.?)(\d*))(.)(m2)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "p.TeaserOffer-loc"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.MiniData-row"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "strong.TeaserOffer-price-num"), '(\d)(.*)( *)(€)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h3.TeaserOffer-title"), '((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)')
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
       puts JSON.pretty_generate(hashed_properties)
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
    flat_data[:description] = access_xml_text(html, "div.OfferDetails > section > div > p").specific_trim_scrp("\n").strip
    flat_data[:flat_type] = prop[:flat_type]
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "li.OfferSlider-main-item > img","src")
    return flat_data
  end
end
