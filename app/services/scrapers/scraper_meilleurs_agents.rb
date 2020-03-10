class ScraperMeilleursAgents < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.meilleursagents.com/annonces/achat/paris-75000/"
    @source = "MeilleursAgents"
    @xml_first_page = "div.listing-item.search-listing-result__item"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page, "Captcha")
    if !xml[0].to_s.strip.empty?
      hashed_properties = []
      xml.each do |item|
        begin
          hashed_property = extract_each_flat(item)
          hashed_properties.push(hashed_property) if is_property_clean(hashed_property)
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          next
        end
      end
      enrich_then_insert(hashed_properties)
    else
      puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
    end
  end

  private

  def extract_each_flat(item)
    hashed_property = {}
    hashed_property[:link] = access_xml_link(item, "a.listing-item__picture-container", "href")[0].to_s
    hashed_property[:images] = ["https:" + access_xml_link(item, "img.listing-item__picture", "src")[0].to_s]
    hashed_property[:area] = access_xml_text(item, "div.text--muted.text--small").area_translator_scrp
    hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
    hashed_property[:surface] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
    hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '\d(.)*(pi(è|e)ce(s?))').to_float_to_int_scrp
    hashed_property[:price] = access_xml_text(item, "div.listing-price.margin-bottom").to_int_scrp
    hashed_property[:source] = @source
    hashed_property[:provider] = "Agence"
    hashed_property[:description] = "Aouch! Ding Dong n'est pas en mesure de vous fournir une description pour ce bien."
    return hashed_property
  end
end
