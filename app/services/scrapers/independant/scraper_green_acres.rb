class Independant::ScraperGreenAcres < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "GreenAcres"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.green-acres.fr" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = access_xml_text(item, "div.item-details > ul > li.details-component.in-meters.align-center").tr("\r\n\t", "").to_int_scrp
          access_xml_text(item, "div.item-details > ul > li:nth-child(2)").empty? ? hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h3.item-title.has-summary"), "(\d+)(.?)(pi(e|è)ce(s?))").to_int_scrp : hashed_property[:rooms_number] = access_xml_text(item, "div.item-details > ul > li:nth-child(2)").to_int_scrp
          next if hashed_property[:rooms_number] == 0
          hashed_property[:price] = access_xml_text(item, "p.item-price").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, "#mainInfoAdvertPage > div > ul"), '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "a.item-location > p"))
            hashed_property[:description] = access_xml_text(html, "#DescriptionDiv > p").specific_trim_scrp("\n").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "#links > div.item.active > div > div.vcenter > span > img", "src")
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
