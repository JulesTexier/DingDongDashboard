class Independant::ScraperVillaret < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Villaret"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.villaret-immobilier.com" + access_xml_link(item, "a.link-product", "href")[0].to_s[2..-1]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.product-criteres"), '(\d+)(.?)(m)').to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.product-city"))
          hashed_property[:rooms_number] = access_xml_text(item, "div.product-type").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.product-price").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.product-desc").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = "+33153447474"
            hashed_property[:images] = []
            access_xml_link(html, "#slider_product > div > a > img", "src").each do |img|
              hashed_property[:images].push("https://www.villaret-immobilier.com/" + img.gsub!("../", ""))
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
