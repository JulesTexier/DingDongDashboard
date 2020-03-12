class ScraperBienIci < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @start_url = "https://www.bienici.com/recherche/achat/paris-75000?tri=publication-desc"
    @source = "BienIci"
    @xml_first_page = "div.detailsContainer"
  end

  def extract_first_page
    xml = fetch_main_page(@start_url, @xml_first_page, "Dynamic", "detailsContainer")
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.bienici.com" + access_xml_link(item, "a.detailedSheetLink", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), '(\d+(,?)(\d)?)(.)m').to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.cityAndDistrict"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:rooms_number] = 1 if regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), "(S|s)tudio") == "Studio"
        hashed_property[:price] = regex_gen(access_xml_text(item, "span.thePrice"), '(\d)(.*)(€)').to_int_scrp
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
    html = fetch_dynamic_page(prop[:link], "detailedSheetContainer", 0)
    flat_data[:link] = prop[:link]
    flat_data[:surface] = prop[:surface]
    flat_data[:area] = prop[:area]
    flat_data[:rooms_number] = prop[:rooms_number]
    flat_data[:price] = prop[:price]
    flat_data[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "div.allDetails").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
    flat_data[:description] = access_xml_text(html, "div.descriptionContent").specific_trim_scrp("\n\t\r").strip
    flat_data[:flat_type] = regex_gen(access_xml_text(html, "div.titleInside h1"), "Achat(.)(\w+)").gsub("Achat ", "").capitalize
    flat_data[:floor] = perform_floor_regex(flat_data[:description])
    flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
    flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
    flat_data[:provider] = "Agence"
    flat_data[:source] = @source
    flat_data[:images] = access_xml_link(html, "div.w > img", "src")
    return flat_data
  end
end
