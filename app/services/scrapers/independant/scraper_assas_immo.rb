class Independant::ScraperAssasImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Assas Immo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.assasimmobilier.com" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(3)"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "a > figure > figcaption > p:nth-child(2) > span").tr("^0-9", "").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "a > figure > div > ul > li:nth-child(2)"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "a > figure > div > ul > li:nth-child(1)"))
          hashed_property[:area] = perform_district_regex(hashed_property[:link])
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.descriptif").strip
            hashed_property[:agency_name] = "Assas Immobilier"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_text(html, "section#annonce_profil").each_line do |line|
              hashed_property[:images].push("https://www.assasimmobilier.com" + line.split("src:'")[1].split("', title:")[0]) if line.include?("items.push({ src:'/datas/biens")
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
