class ScraperSuperImmo < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.superimmo.com/achat/ile-de-france/paris?sort=created_at"
    @source = "SuperImmo"
    @xml_first_page = "section > div.media-body"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://superimmo.com" + access_xml_link(item, "p > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(item.text, '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(item.text, '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(item.text, '(\d)(.*)(€)').to_int_scrp
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
    flat_data[:bedrooms_number] = regex_gen(access_xml_text(html, "h1"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "p.description").strip
    flat_data[:flat_type] = access_xml_text(html, "#itemprop-appartements")
    flat_data[:agency_name] = access_xml_text(html, "header > div.media-body > b")
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "a.fancybox img", "src")
    return flat_data
  end
end
