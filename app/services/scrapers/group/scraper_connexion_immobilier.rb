class Group::ScraperConnexionImmobilier < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Connexion Immobilier"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = regex_gen(access_xml_link(item, "a.gp", "href")[0], "(&url=http)(.)*").gsub("&url=", "")
          hashed_property[:surface] = access_xml_text(item, ".surface > span").to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".city > nobr"))
          hashed_property[:rooms_number] = access_xml_text(item, ".rooms").to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".price").to_s.force_encoding("UTF-8").split("€")[0].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.desc").strip.gsub(/[^[:print:]]/, "")
            hashed_property[:bedrooms_number] = access_xml_text(item, ".bedrooms").to_int_scrp if !access_xml_text(item, ".bedrooms").empty?
            hashed_property[:floor] = access_xml_text(item, ".floor").gsub(/[^[:print:]]/, "").include?("RDC") ?  0 : access_xml_text(item, ".floor").to_int_scrp
            hashed_property[:has_elevator] = (access_xml_link(item, ".floor", "class")[0].include?("nolift") || access_xml_link(item, ".floor", "class")[0].include?("floorrdc")) ? false : true
            hashed_property[:flat_type] = get_type_flat(hashed_property[:link])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:agency_name] = access_xml_text(html, "#detformcall > div.txt > p.name")
            hashed_property[:contact_number] = access_xml_text(html, "#detformcall > div.txt > p.desktoponly.tel").gsub(" ", "")
            imgs = access_xml_link(html, '[itemprop="image"]', "src")
            hashed_property[:images] = []
            imgs.each do |img|
              hashed_property[:images].push(img) if !img.nil?
            end
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
