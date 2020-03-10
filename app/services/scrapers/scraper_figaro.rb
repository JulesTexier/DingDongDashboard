class ScraperFigaro < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://immobilier.lefigaro.fr/annonces/resultat/annonces.html?transaction=vente&location=paris&priceMin=100000&priceMax=5000000&areaMin=8&areaMax=500&type=appartement,atelier,chambre,chambre%20d%20hote,duplex,loft,chalet,chateau,ferme,gite,hotel,hotel%20particulier,maison,manoir,moulin,peniche,propriete,villa&fromSearchButton=%22%22&sort=5"
    @source = "Figaro"
    @xml_first_page = "div.item-main-infos"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://immobilier.lefigaro.fr" + access_xml_link(item, "a.js-link-ei", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = access_xml_text(item, "h2 > a > span").area_translator_scrp
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, "span.price-label"), '(\d)(.*)(€)').to_int_scrp
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link, a bad xml extraction or a new website unscrappable yet.\n\n"
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
    flat_data[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.unstyled.flex").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "p.description.js-description").specific_trim_scrp("\n").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "div.container-h1 > h1"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
    flat_data[:agency_name] = access_xml_text(html, "span.agency-name")
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "a.image-link.default-image-background", "href")
    return flat_data
  end
end
