class Independant::ScraperParisPrestigeImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Paris prestige immo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.parisprestigeimmo.fr" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '-(\d){1,}-piece').to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".price").strip.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "article > p.comment").gsub(/[^[:print:]]/, "").strip
            details = access_xml_text(html, ".summary > ul:nth-child(2)").gsub(/[^[:print:]]/, "").downcase.gsub(" ", "").remove_acc_scrp
            hashed_property[:surface] = regex_gen(details, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
            hashed_property[:floor] = regex_gen(details, 'etage(\d){1,}e').to_int_scrp
            raw_bedrooms = hashed_property[:description].transform_litteral_numbers.gsub(" ", "")
            hashed_property[:bedrooms_number] = regex_gen(raw_bedrooms, '(\d){1,}chambre').to_int_scrp if raw_bedrooms.match(/(\d){1,}chambre/i).is_a?(MatchData)
            hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
            hashed_property[:subway_infos] = perform_subway_regex(access_xml_text(html, ".title > h1") + hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:agency_name] = access_xml_text(html, "aside  > h4")
            hashed_property[:contact_number] = access_xml_link(html, "aside  > p > a", "href")[0].gsub("tel:0033", "").convert_phone_nbr_scrp
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, ".slideshow > img", "src")
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
