class Independant::ScraperSotheby < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Sotheby"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.proprietesparisiennes-sothebysrealty.com" + access_xml_link(item, "a", "href")[0].to_s
          hashed_property[:surface] = access_xml_text(item, "span.ico_surface").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "figcaption > p:nth-child(1) > span"))
          hashed_property[:rooms_number] = access_xml_text(item, "span.ico_piece > span").to_float_to_int_scrp + 1
          hashed_property[:price] = regex_gen(access_xml_text(item, "figcaption > p:nth-child(2) > span"), '(\d)(.*)(€)').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "figcaption > p:nth-child(3)"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.detailDescriptif > p").specific_trim_scrp("\n").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = ["https://www.proprietesparisiennes-sothebysrealty.com" + access_xml_link(html, "img.slideshow__img.lazyLoadImg.js-img-loading-overlay", "data-src")[0].to_s]
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
