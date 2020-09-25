class Hub::ScraperFigaro < Scraper
  attr_accessor :source, :params, :properties

  def initialize(sp_id = nil)
    @source = "Figaro"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = access_xml_link(item, "a.js-link-ei", "href")[0].to_s
          hashed_property[:link] = link.to_s.strip.empty? ? access_xml_link(item, "a.js-link-plf", "href")[0].to_s : "https://immobilier.lefigaro.fr" + link
          hashed_property[:link] = access_xml_link(item, "a.js-link-ei9", "href")[0].to_s if hashed_property[:link] == ""
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h2"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2 > a > span").tr("\n\t", ""), args.zone)
          hashed_property[:flat_type] = get_type_flat(access_xml_link(item, "a.js-link-ei", "title")[0]) unless access_xml_link(item, "a.js-link-ei", "title")[0].nil?
          hashed_property[:rooms_number] = hashed_property[:flat_type] == "Studio" ? 1 : regex_gen(access_xml_text(item, "h2"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "span.price-label"), '(\d)(.*)(€)').to_int_scrp
          hashed_property[:is_new_construction] = access_xml_text(item, 'span.label-brand').include?("Avec Figaro Immoneuf")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            if hashed_property[:link].include?("https://proprietes.lefigaro.fr")
              hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul").tr("\n\r\t", ""), '(\d+)(.?)(chambre(s?))').to_int_scrp
              hashed_property[:description] = access_xml_text(html, "p#js-description").specific_trim_scrp("\n").strip
              hashed_property[:agency_name] = access_xml_text(html, "span.societe.js-societe").tr("\n\t", "")
              hashed_property[:images] = access_xml_link(html, "#js-picture-main", "src")
            elsif hashed_property[:link].include?("https://www.explorimmoneuf.com/")
              hashed_property[:images] = access_xml_link(html, "img.img-player-in-page", "src")
              hashed_property[:description] = access_xml_text(html, "div.container-description-text").specific_trim_scrp("\n").strip
            else
              hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.unstyled.flex").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
              hashed_property[:description] = access_xml_text(html, "p.description.js-description").specific_trim_scrp("\n").strip
              hashed_property[:agency_name] = access_xml_text(html, "span.agency-name").tr("\n\t", "")
              hashed_property[:images] = access_xml_link(html, "a.image-link.default-image-background", "href")
            end
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
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
