class Independant::ScraperCapitaleImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Capitale Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.capitale-immobilier.com" + access_xml_link(item, "a", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "p.item_info").tr("\n", ""), '(\d+(.?)(\d*))(.*?)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_link(item, "a", "title")[0])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "p.item_info").tr("\n", "").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:price] = access_xml_text(item, "p.item_price").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_link(item, "a", "title")[0])
          next if hashed_property[:area] == "N/C" || hashed_property[:flat_type].match(/(commerce|parking|cave)/i).is_a?(MatchData)
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.annonce_description_dpe > p").tr("\n\r\t", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = access_xml_text(html, "div.annonce_form_contact > div > p:nth-child(2)").convert_phone_nbr_scrp
            hashed_property[:images] = access_xml_link(html, "#thumbs_carousel > div > div > div > a", "href").map { |img| "https://www.capitale-immobilier.com" + img }
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
