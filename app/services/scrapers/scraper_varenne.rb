class ScraperVarenne < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.agencevarenne.fr/fr/liste-biens?search=1&clicarrondissement=0&arrondissement%5B0%5D=5&arrondissement%5B1%5D=6&arrondissement%5B2%5D=7&arrondissement%5B3%5D=13&arrondissement%5B4%5D=14&arrondissement%5B5%5D=15&arrondissement%5B6%5D=1&arrondissement%5B7%5D=2&arrondissement%5B8%5D=3&arrondissement%5B9%5D=4&arrondissement%5B10%5D=8&arrondissement%5B11%5D=9&arrondissement%5B12%5D=16&arrondissement%5B13%5D=17"
    @source = "Agence Varenne"
    @main_page_cls = "div.row-ct-liste"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
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
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
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
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
