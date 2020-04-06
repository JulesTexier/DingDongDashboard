class ScraperParisMontmartreImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://paris-montmartre-immobilier.fr/advanced-search/?keyword=PARIS&status=vente&type=&bedrooms=&min-area=&max-price=&bathrooms=&max-area=&min-price="
    @source = "Paris Montmartre Immo"
    @main_page_cls = "div.property-item"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, ".property-title>a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, ".property-title>a"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".property-title"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = regex_gen(item.text, '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          detail = access_xml_text(html, "#detail").strip.tr(" ", "")
          hashed_property[:bedrooms_number] = regex_gen(detail, 'Chambre(s?):(\d)*').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "#description>p").strip
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = regex_gen(detail, 'Etage(s?):(\d)*').to_int_scrp
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "img.sp-image", "src")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
