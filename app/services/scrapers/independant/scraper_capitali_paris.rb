class Independant::ScraperCapitaliParis < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Capitali Paris"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link_brut = access_xml_link(item, "div.row > div.col-sm-6 > a", "href")[0].to_s
          hashed_property[:link] = "http://www.capitali-paris.com" + link_brut[2..link_brut.length]
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".carac"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".carac > div:nth-child(3)").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".carac"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "ul.list-group:nth-child(2) > li.list-group-item:nth-child(1) > div").split("Code postal")[1])
            hashed_property[:description] = access_xml_text(html, ".description").gsub("\t", "").gsub("\n", "").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, 'div.col-sm-6:nth-child(2)').tr("\r\t\n", ""))
            hashed_property[:agency_name] = "Capitali Paris"
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.img", "style").map { |img| "http://www.capitali-paris.com" + img.split("('..")[1].split("')")[0] }
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
