class Group::ScraperJunot < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Junot"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.title-article", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "a.title-article > span:nth-child(1)"))
          hashed_property[:rooms_number] = access_xml_text(item, 'span[itemprop="numberOfRooms"]').to_int_scrp
          hashed_property[:surface] = access_xml_text(item, 'span[itemprop="floorSize"]').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, ".price> span:nth-child(1) > span:nth-child(1)").gsub(" ", "").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, ".description").strip
            details = access_xml_text(item, ".right-block-top-right").strip.gsub(" ", "").gsub(/[^[:print:]]/, "").downcase
            hashed_property[:bedrooms_number] = regex_gen(details, 'chambre(s)+:(\d)*').to_int_scrp if details.match(/chambre(s)+:(\d)*/i).is_a?(MatchData)
            details.match(/ascenseur:oui/i).is_a?(MatchData) ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:flat_type] = get_type_flat(access_xml_text(item, ".appartement"))
            floor = regex_gen(access_xml_text(html, 'li[itemprop="floorLevel"]').gsub(" ", ""), '(\d*)/')
            floor.empty? ? hashed_property[:floor] = nil : hashed_property[:floor] = floor.to_int_scrp
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul.slideshow > li > img", "src")
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
