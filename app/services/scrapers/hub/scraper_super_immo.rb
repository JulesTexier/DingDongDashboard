class Hub::ScraperSuperImmo < Scraper
  attr_accessor :source, :params, :properties

  def initialize(sp_id = nil)
    @source = "SuperImmo"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://superimmo.com" + access_xml_link(item, "p > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "b:nth-child(2)"), args.zone)
          hashed_property[:rooms_number] = regex_gen(item.text, '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if hashed_property[:rooms_number] == 0
            ## if we find a bedrooms number, then we can determinate rooms number, otherwise next.
            bedrooms_number = regex_gen(item.text, '(\d+)(.?)(chambre(s?))').to_float_to_int_scrp
            hashed_property[:rooms_number] = bedrooms_number + 1 if bedrooms_number > 0
            next if hashed_property[:rooms_number] == 0
          end
          hashed_property[:price] = regex_gen(access_xml_text(item, "p > a > b.prix"), '(\d)(.*)(€)').to_int_scrp
          hashed_property[:is_new_construction] = access_xml_text(item, 'p.js-desc-truncate').tr("\r\n", "").partition(" ").first == "Programme"
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html, "h1"), '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "p.description").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "#itemprop-appartements"))
            hashed_property[:agency_name] = access_xml_text(html, "header > div.media-body > b")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "a.fancybox img", "src")
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
            i += 1
            break if i == limit
          end
        rescue StandardError => e
          error_outputs(e, @source)
          next
        end
      end
    end
    return @properties
  end
end
