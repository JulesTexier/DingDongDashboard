class Group::ScraperCentury < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Century21"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.century21.fr" + access_xml_link(item, "a.tw-block", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "h4.tw-text-c21-grey-medium"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h3.tw-leading-none"), args.zone)
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h4.tw-text-c21-grey-medium"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.price"), '(\d)(.*)(€)').to_int_scrp
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "#focusAnnonceV2 > section.precision > div.desc-fr > p").specific_trim_scrp("\n").strip
            hashed_property[:flat_type] = get_type_flat(access_xml_text(html, "div.content > div > h1"))
            hashed_property[:agency_name] = access_xml_text(html, "span.agency-name")
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link_matchdata_src(html, "a.fancybox", "href", "(#popupReseauxSociauxAG)", "https://www.century21.fr")
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
