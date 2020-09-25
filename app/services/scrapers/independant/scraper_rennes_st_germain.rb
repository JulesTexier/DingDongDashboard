class Independant::ScraperRennesStGermain < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Rennes Saint Germain"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.rennes-st-germain.com" + access_xml_link(item, "div.caption-footer > a.btn-primary", "href")[0]
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(piece(s?))(.?)(\d+)').to_int_scrp
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(chambre\(s\))(.?)(\d+)').to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.flash-infos").remove_acc_scrp, '(Surface)(.?)(\d+(.?)(\d*))(.?)(m)').tr("/[A-z]/", "").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "div.ville"))
          hashed_property[:price] = access_xml_text(item, "div.left-caption").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "div.value > span"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "article.col-md-6.corp-elementDt6.elementDt > p").tr("\n", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33153630440"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "ul.imageGallery > li > img", "src").map { |img| "https:" + img }
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
