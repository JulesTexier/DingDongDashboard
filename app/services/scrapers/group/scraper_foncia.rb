class Group::ScraperFoncia < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Foncia"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://fr.foncia.com" + access_xml_link(item, "a", "href")[0].to_s
          next if hashed_property[:link].include?("programme-neuf")
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.MiniData-row"), '(\d+(.?)(\d*))(.)(m2)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "p.TeaserOffer-loc"), args.zone)
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.MiniData-row"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "strong.TeaserOffer-price-num"), '(\d)(.*)( *)(€)').to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h3.TeaserOffer-title"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.OfferDetails > section > div > p").specific_trim_scrp("\n").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "li.OfferSlider-main-item > img", "src")
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
