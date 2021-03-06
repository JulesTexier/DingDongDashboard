class Proxy::ScraperMeilleursAgents < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "MeilleursAgents"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.listing-item__picture-container", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.text--muted.text--small"), args.zone)
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.listing-characteristic.margin-bottom"))
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.listing-characteristic.margin-bottom"), '\d(.)*(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:rooms_number] = 1 if access_xml_text(item, "div.listing-characteristic.margin-bottom").downcase.include?("studio")
          next if hashed_property[:rooms_number] == 0
          hashed_property[:price] = access_xml_text(item, "div.listing-price.margin-bottom").to_int_scrp
          hashed_property[:has_elevator] = nil
          hashed_property[:floor] = nil
          hashed_property[:source] = @source
          hashed_property[:provider] = "Agence"
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page_proxy_auth(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "section.listing-informations > div:nth-child(2)").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.listing-slideshow__link", "href").map { |img| "https://" + img[2..-1] }
            hashed_property[:contact_number] = access_xml_link(html, "a.btn.btn--secondary.full-width.margin-right-double", "href")[0].gsub("tel:", "").convert_phone_nbr_scrp
            hashed_property[:agency_name] = access_xml_text(html, "a.contact-form__subtitle")
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
