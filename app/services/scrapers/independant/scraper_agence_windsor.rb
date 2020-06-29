class Independant::ScraperAgenceWindsor < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Agence Windsor"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2.announce-title"))
          next if hashed_property[:area] == "N/C"
          hashed_property[:link] = access_xml_link(item, "h2.announce-title > a", "href")[0]
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2.announce-title").remove_acc_scrp.tr(" ", ""), '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "p.announce-infos"), '(.?)(\d+(.?)(\d*))(.?)(m)').tr("/[A-z]/", "").to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "p.announce-infos > b").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "p.announce-infos").remove_acc_scrp)
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.announce-description").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = access_xml_text(html, "div.col-lg-6.col-xl-5.offset-xl-1 > div.mb-5 > div:nth-child(3) > b").convert_phone_nbr_scrp
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.carousel-inner.gallery > div.carousel-item > a", "href")
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
