class Hub::ScraperPap < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "PAP"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          link = access_xml_link(item, "a.item-title", "href")[0]
          next if link.match("(#dialog_mensualite|www.immoneuf.com/|construiresamaison.com/)").is_a?(MatchData)
          hashed_property[:link] = "https://www.pap.fr" + access_xml_link(item, "a.item-title", "href")[0]
          hashed_property[:surface] = regex_gen(access_xml_text(item, "ul.item-tags"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.h1"), args.zone)
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.item-description"), args.zone) if hashed_property[:area] == "N/C"
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "ul.item-tags"), '(\d+)(.?)(pi)').to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "span.item-price"), '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "ul.item-tags.margin-bottom-20").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "div.item-description").specific_trim_scrp("\n\t\r").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "h1.item-title"))
            hashed_property[:provider] = "Particulier"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.owl-thumbs.sm-hidden img", "src")
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
