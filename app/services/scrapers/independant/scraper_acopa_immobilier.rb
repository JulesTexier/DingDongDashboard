class Independant::ScraperAcopaImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Acopa Immobilier"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    # These tricky lines are made to get the nonce variable, required for authenticity of the post request
    # https://i.ytimg.com/vi/KEkrWRHCDQU/maxresdefault.jpg
    doc = fetch_static_page("https://www.acopa-immobilier.fr/")
    doc.css("script").each do |script|
      if script.content.include?("nonce")
        nonce = regex_gen(regex_gen(script.content, "var nonce = (.)*'"), "'(.)*'").gsub("'", "")
        @http_request = "action=corn_realestateSearch&nonce=#{nonce}&param=budget_max=1560000&surface_min=0&rooms_min=0&ville=&typetransacselected=vente&mapselected=paris&zoneselected=&lastcriteria=undefined"
        break if !nonce.empty?
      end
    end
    i = 0

    self.params.each do |args|
      args.http_request[1] = @http_request
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.thb", "href")[0].to_s
          hashed_property[:area] = perform_district_regex("Paris " + regex_gen(hashed_property[:link], 'paris(\d){1,}(\/)').to_int_scrp.to_s)
          hashed_property[:price] = access_xml_text(item, "div:nth-child(2) > div:nth-child(3) > strong:nth-child(1)").to_int_scrp
          hashed_property[:rooms_number] = access_xml_text(item, "h3").to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div:nth-child(2) > div:nth-child(6) > strong:nth-child(1)"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.col-md-3:nth-child(8)").strip
            details = access_xml_text(html, ".fiche").strip.gsub(" ", "").gsub(/[^[:print:]]/, "")
            hashed_property[:bedrooms_number] = regex_gen(details, 'Chambres:(\d){1,}').to_int_scrp
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h3"))
            hashed_property[:agency_name] = access_xml_text(html, "#contactagences > strong")
            hashed_property[:contact_number] = access_xml_link(html, "a.tel", "href")[0].gsub(" ", "").gsub("tel:", "")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.thb", "data-image").select { |img| !img.nil? }
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
