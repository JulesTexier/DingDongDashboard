class Group::ScraperEraFrance < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "ERA France"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = "https://www.erafrance.com" + access_xml_link(item, "a", "href")[0].to_s.gsub("..", "")
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:surface] = access_xml_text(item, "div.bien_infos > p").to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.prix"), '(\d+)(.?)(\d+)(.?)(\d+)(...)dont').tr("^0-9", "") != "" ? regex_gen(access_xml_text(item, "div.prix"), '(\d+)(.?)(\d+)(.?)(\d+)(...)dont').tr("^0-9", "").to_float_to_int_scrp : access_xml_text(item, "div.prix").tr("^0-9", "").to_float_to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".bien_type"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.description.principale").tr("\n\t", "").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "h2.titre_bien"))
            hashed_property[:agency_name] = access_xml_text(html, ".contact_agence_details > a > h3").tr("\n\r\t", "")
            agency_area = perform_district_regex(access_xml_text(html, "p.contact_agence_ville"), args.zone)
            desc_area = perform_district_regex(hashed_property[:description], args.zone)
            hashed_property[:area] = desc_area != agency_area && desc_area != "N/C" ? desc_area : agency_area
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul.slides > li > a", "href")
            hashed_property[:images].collect! { |img| "https://www.erafrance.com" + img.gsub("..", "") }
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
