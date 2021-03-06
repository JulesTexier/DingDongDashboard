class Independant::ScraperVillaret < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Villaret"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = "https://www.villaret-immobilier.com" + access_xml_link(item, "a.link-product", "href")[0].to_s[2..-1]
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.product-criteres"), '(\d+)(.?)(m)').to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.product-city"))
          hashed_property[:rooms_number] = access_xml_text(item, "div.product-type").to_int_scrp
          price = access_xml_text(item, "div.product-price")
          hashed_property[:price] = price.include?("dont") ? price.split("dont")[0].to_int_scrp : access_xml_text(item, "div.product-price").to_int_scrp
          next if hashed_property[:price].nil?
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:flat_type] = "N/C"
            hashed_property[:description] = access_xml_text(html, "div.product-desc").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:contact_number] = "+33153447474"
            hashed_property[:images] = []
            access_xml_link(html, "#slider_product > div > a > img", "src").each do |img|
              hashed_property[:images].push("https://www.villaret-immobilier.com/" + img.gsub!("../", ""))
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
