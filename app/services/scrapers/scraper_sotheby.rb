class ScraperSotheby < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.proprietesparisiennes-sothebysrealty.com/fr/vente-proprietes-appartements-luxe-paris/tri=id&ordre=DESC"
    @source = "Sotheby"
    @main_page_cls = "div.annonce_listing"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @wait = 0
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.proprietesparisiennes-sothebysrealty.com" + access_xml_link(item, "a", "href")[0].to_s
        hashed_property[:surface] = access_xml_text(item, "span.ico_surface").to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "figcaption > p:nth-child(1) > span"))
        hashed_property[:rooms_number] = access_xml_text(item, "span.ico_piece > span").to_float_to_int_scrp + 1
        hashed_property[:price] = regex_gen(access_xml_text(item, "figcaption > p:nth-child(2) > span"), '(\d)(.*)(€)').to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "figcaption > p:nth-child(3)"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.detailDescriptif > p").specific_trim_scrp("\n").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:source] = @source
          hashed_property[:images] = ["https://www.proprietesparisiennes-sothebysrealty.com" + access_xml_link(html, "img.slideshow__img.lazyLoadImg.js-img-loading-overlay", "data-src")[0].to_s]
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
