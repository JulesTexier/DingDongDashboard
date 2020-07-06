class Independant::ScraperParisSeine < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Paris Seine"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_text(item, "div.picto.text-uppercase") == "Vendu par l'agence"
          hashed_property = {}
          hashed_property[:link] = "https://www.paris-seine-immobilier.com/" + access_xml_link(item, "a.titreBien", "href")[0].gsub("../", "")
          hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "div.carac"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.code_postal"))
          hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "div.carac").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:price] = access_xml_array_to_text(item, "div.carac > div:nth-child(3)").split("\u0080")[0].to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, 'div.col-sm-6:nth-child(2)').tr("\r\t\n", ""))
            hashed_property[:description] = access_xml_text(html, "div.description").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33145446600"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_raw(html, "div#diapoDetail").each do |imgs|
              access_xml_link(imgs, "div.img", "style").each do |img|
                hashed_property[:images].push("https://www.paris-seine-immobilier.com/" + img.split("../")[1].split("')")[0])
              end
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
