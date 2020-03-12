class ScraperGreenAcres < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.green-acres.fr/fr/prog_show_properties.html?searchQuery=order-date_d-lg-fr-cn-fr-i-24-hab_appartement-on-hab_house-on-city_id-dp_75"
    @source = "GreenAcres"
    @xml_first_page = "figure"
  end

  def extract_first_page
    xml = fetch_first_page(@url, @xml_first_page)
    puts xml
    hashed_properties = []
    xml.each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.green-acres.fr" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = access_xml_text(item, "div.item-details > ul > li.details-component.in-meters.align-center").tr("\r\n\t", "").to_int_scrp
        hashed_property[:area] = access_xml_raw(item, "span.advert-location-text-4")
        hashed_property[:rooms_number] = access_xml_text(item, "div.item-details > ul > li.details-component.align-center")
        hashed_property[:price] = access_xml_text(item, "p.item-price").to_int_scrp
        puts JSON.pretty_generate(hashed_property)
        hashed_properties.push(extract_each_flat(hashed_property)) if is_property_clean(hashed_property)
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        puts item
        puts e.message
        next
      end
    end
    # enrich_then_insert(hashed_properties)
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
