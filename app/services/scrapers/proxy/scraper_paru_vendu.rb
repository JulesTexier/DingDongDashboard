class Proxy::ScraperParuVendu < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "ParuVendu"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_link(item, "a:nth-child(2)", "href")[0].nil?
          hashed_property = {}
          hashed_property[:link] = "https://www.paruvendu.fr" + access_xml_link(item, "a:nth-child(2)", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h3").tr("\r\n\t", "").remove_acc_scrp, '\d{1,3}\sm').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "cite"), args.zone)
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h3").tr("\r\n\t", "").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_float_to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.ergov3-txtannonce > div").tr("\r\n€", "").to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page_proxy_auth(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div#txtAnnonceTrunc").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "#itemprop-appartements"))
            hashed_property[:agency_name] = access_xml_text(html, "header > div.media-body > b")
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.fcbx_photo3 > p > span > img", "src").map { |img| img.gsub("sizecrop_88x88", "sizecrop_1000x1000") }
            hashed_property[:images] = access_xml_link(html, "ul.slides > li > img", "src") if hashed_property[:images].empty?
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
  end
end
