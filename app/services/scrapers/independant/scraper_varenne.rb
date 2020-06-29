class Independant::ScraperVarenne < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Agence Varenne"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.agencevarenne.fr" + access_xml_link(item, ".bien-infos > h3 > a", "href")[0].to_s
          hashed_property[:area] = perform_district_regex(access_xml_text(item, ".bien-infos > p:nth-child(2) > a:nth-child(1)"))
          hashed_property[:price] = access_xml_text(item, "ul.list-bien-infos > li:nth-child(4)").to_int_scrp
          hashed_property[:rooms_number] = access_xml_text(item, "ul.list-bien-infos > li:nth-child(1)").to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "ul.list-bien-infos > li:nth-child(3)"), '(\d+(,?)(\d*))(.)(m)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.widget")) if hashed_property[:area] == "N/C"
            hashed_property[:bedrooms_number] = access_xml_text(item, "ul.list-bien-infos > li:nth-child(2)").to_int_scrp
            hashed_property[:description] = access_xml_text(html, ".bien-annexe > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > div:nth-child(1) > p").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "div.col-md-8:nth-child(2) > div:nth-child(1) > h4:nth-child(2)"))
            hashed_property[:agency_name] = @source + " - " + access_xml_text(html, ".nego-image-desc > p:nth-child(1) > a:nth-child(1)")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            images = access_xml_link(html, ".item", "style")
            hashed_property[:images] = []
            images.each do |img|
              if !img.nil?
                img_link = "https://www.agencevarenne.fr" + regex_gen(img, "url((.)*)").gsub("url('", "").gsub("')\;", "")
                hashed_property[:images].push(img_link)
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
