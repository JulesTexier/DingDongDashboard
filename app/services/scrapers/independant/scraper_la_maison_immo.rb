class Independant::ScraperLaMaisonImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "La Maison Immo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.lamaisonimmo.fr" + access_xml_link(item, "a:nth-child(1)", "href")[0].to_s.gsub("..", "")
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "a:nth-child(1) > h3"))
          access_xml_text(item, "span.listing_price").include?("dont") ? hashed_property[:price] = regex_gen(access_xml_text(item, "span.listing_price").gsub(" ", ""), '(\d)*(.)*(dont)').to_int_scrp : hashed_property[:price] = access_xml_text(item, "span.listing_price").to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, ".listing_criteres"), '(\d+)(\s)Pi').to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, ".listing_criteres"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, ".description").strip
            hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, ".listing_criteres").gsub(" ", ""), '(,)(\d*)(Ch)').to_int_scrp if access_xml_text(item, ".listing_criteres").gsub(" ", "").match(/(,)(\d*)(Ch)/i).is_a?(MatchData)
            hashed_property[:flat_type] = get_type_flat(hashed_property[:description])
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            images = access_xml_link(html, "div.img", "style")
            images.each do |image_url|
              hashed_property[:images].push("https://www.lamaisonimmo.fr" + regex_gen(image_url.gsub!("background:url('..", ""), "(.)*(.jpg)"))
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
