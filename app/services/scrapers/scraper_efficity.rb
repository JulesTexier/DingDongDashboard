class ScraperEfficity < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.efficity.com/achat-immobilier/results/?inputed_location=8075056&property_type=1&max_price=&min_nb_of_rooms=1"
    @source = "Efficity"
    @xml_first_page = "div.annonce"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page)
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        
        hashed_property[:link] = "https://www.efficity.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item,'a > figcaption > h3 > span > span'), '(75)$*\d+{3}')
        hashed_property[:price] = regex_gen(access_xml_text(item, 'a > div > div > strong > span'), '(\d)(.*)(€)').to_int_scrp
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    puts "*"*10
    enrich_then_insert(hashed_properties)
  end

  private

  def extract_each_flat(prop)
    flat_data = {}
    html = fetch_static_page(prop[:link])
    flat_data[:link] = prop[:link]
    flat_data[:surface] = prop[:surface]
    flat_data[:area] = prop[:area]
    flat_data[:rooms_number] = regex_gen(access_xml_text(html,'#nom-bien'), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
    flat_data[:price] = prop[:price]
    flat_data[:bedrooms_number] = regex_gen(access_xml_text(html, ".resume-picto"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "div.detail-desc-text").strip
    flat_data[:flat_type] = access_xml_text(html,'#nom-bien').split('|')[0].tr(' ','')
    flat_data[:agency_name] = "Efficity"
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, ".cbp-lightbox", "href")
    flat_data[:images].collect! {|img| img.clean_img_link_https}
    return flat_data
  end
end
