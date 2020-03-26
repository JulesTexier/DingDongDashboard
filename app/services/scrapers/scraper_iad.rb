class ScraperIad < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.iadfrance.fr/rechercher/annonces?generic_type%5B%5D=AP&generic_type%5B%5D=MV&surface_min=&surface_max=&price_min=&price_max=&id=&departments=Paris&tags_list=%5B%7B%22type%22%3A%22departments%22%2C%22value%22%3A%22Paris%22%2C%22name%22%3A%22Paris+%22%7D%5D&transaction_type=Vente&frequency=Journali%C3%A8re"
    @source = "Iad"
    @main_page_cls = "div.c-offer"
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
        next if access_xml_text(item, '.button__highlight') == "Sous compromis"
        hashed_property = {}
        hashed_property[:link] = "https://www.iadfrance.fr" + access_xml_link(item,'.c-offer__title','href')[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item,'.c-offer__title').strip, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item,'.c-offer__localization').strip, '(75)$*\d+{3}')
        hashed_property[:description] = access_xml_text(item, '.c-offer__description').strip
        hashed_property[:rooms_number] = access_xml_text(item, '.c-offer__footer.row > div:nth-child(2)').strip.to_float_to_int_scrp
        hashed_property[:price] = regex_gen(access_xml_text(item, '.c-offer__price').strip, '(\d)(.*)(€)').to_int_scrp

        if is_property_clean(hashed_property)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, '.offer__description > p').strip
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, '.offer__information-2').strip.gsub(' ','').gsub(/[^[:print:]]/,''), 'chambre(s?)(\d)*').to_int_scrp
          hashed_property[:bedrooms_number] == 0 ? hashed_property[:bedrooms_number] = regex_gen(hashed_property[:description], '(\d+)(.?)(chambre(s?))').to_int_scrp : nil
          hashed_property[:flat_type] = get_type_flat(access_xml_text(html, '.h1').strip)
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, '.offer__slider-item > img', 'src')
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
    byebug

    return @properties
  end
end
