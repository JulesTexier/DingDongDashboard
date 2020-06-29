class Independant::ScraperEmileGarcin < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Emile Garcin"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = "https://www.emilegarcin.fr/" + access_xml_link(item, "a", "href")[0].gsub("../", "")
          hashed_property[:link] = link.split("?search")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "p.info"), '(\d+)(.?)(m)').to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_link(item, "a", "href")[0].gsub("../", "").split("/")[2].split(".html?")[0])
          hashed_property[:area] = nil if hashed_property[:area] == "N/C"
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "p.info"), '(\d+)(.?)(chambre(s?))').to_int_scrp
          rooms_number = regex_gen(access_xml_text(item, "p.type"), '(\d+)(.?)(pi)').to_int_scrp
          rooms_number = hashed_property[:bedrooms_number] + 1 if rooms_number == 0 || rooms_number.nil?
          hashed_property[:rooms_number] = rooms_number
          price = access_xml_text(item, "p.price")
          hashed_property[:price] = price.include?("dont") ? price.split("dont")[0].to_int_scrp : price.to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "h1.title")) if hashed_property[:area].nil?
            hashed_property[:description] = access_xml_text(html, "div.description").strip.tr("\t\n", "")
            hashed_property[:contact_number] = access_xml_text(html, "div.cont-phone").gsub(" ", "").tr("\t\n", "")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_link(html, "ul.slides > li > a", "href").each do |img|
              hashed_property[:images].push("https://www.emilegarcin.fr/" + img.gsub!("../", ""))
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
