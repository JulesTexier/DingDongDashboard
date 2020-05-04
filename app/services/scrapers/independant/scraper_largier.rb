class Independant::ScraperLargier < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Largier"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.largier.fr" + access_xml_link(item, "a", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "div.moreInfos > ul > li:nth-child(3)").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "figcaption > p:nth-child(1)"))
          hashed_property[:price] = access_xml_text(item, "figcaption > p:nth-child(2)").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.moreInfos > ul > li:nth-child(1)"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)").capitalize
          hashed_property[:rooms_number] = access_xml_text(item, "div.moreInfos > ul > li:nth-child(2)").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.descriptif").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_text(html, "script").each_line do |line|
              hashed_property[:images].push("https://www.largier.fr" + line.split("src:'")[1].split("', title:")[0]) if line.include?("items.push({ src:'/datas/biens")
            end
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
