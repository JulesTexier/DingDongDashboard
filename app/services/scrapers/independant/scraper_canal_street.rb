class Independant::ScraperCanalStreet < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Canal Street"
    @params = fetch_init_params(@source)
    @properties = []
  end


  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.canal-street.fr" + access_xml_link(item, "div.caption-footer > a.btn-primary", "href")[0]
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2").remove_acc_scrp.tr(" ", ""), '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(.?)(\d+(.?)(\d*))(.?)(m)').tr("/[A-z]/", "").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.ville"))
          hashed_property[:price] = access_xml_text(item, "div.left-caption").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h2"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "article.col-md-6.elementDt > p").tr("\n", "").strip
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33142380206"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul.imageGallery > li > img", "src")
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
