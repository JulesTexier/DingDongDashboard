class Independant::ScraperMontparnasse < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Montparnasse Immobilier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = "https://www.montparnasseimmobilier.com/" + access_xml_link(item, "a", "href")[1].gsub("../", "")
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.products-localisation"))
          hashed_property[:description] = access_xml_text(item, "div.products-description").specific_trim_scrp("\n").strip
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.products-description").remove_acc_scrp.specific_trim_scrp("\n"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp
          hashed_property[:surface] = nil if hashed_property[:surface] == 0
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.products-description").remove_acc_scrp.convert_written_number_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:rooms_number] = nil if hashed_property[:rooms_number] == 0
          hashed_property[:price] = access_xml_text(item, "div.products-price").split("dont")[0].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "#box_slider_header_product > div > ul").remove_acc_scrp, '(\d+)(.?)(piece\(s\))').to_int_scrp if hashed_property[:rooms_number].nil?
            hashed_property[:surface] = regex_gen(access_xml_text(html, "#box_slider_header_product > div > ul"), '(\d+)(.?)(\d+)(.?)(m)').to_float_to_int_scrp if hashed_property[:surface].nil?
            hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33142842121"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.item-slider > a", "href").map { |img| "https://www.montparnasseimmobilier.com/" + img.gsub("../", "") }
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
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
