class Group::ScraperImmopolis < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Immopolis"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.arrow > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.wpb_wrapper > ul"), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:price] = regex_gen(access_xml_text(item, "div.list-annonce-prix > div.wpb_wrapper > p"), '(\d+(.?)\d+(.?)(\d*))(.)(,)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "div.wpb_wrapper > ul"), '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.wpb_wrapper > ul"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:area] = perform_district_regex(access_xml_text(html, "div.font-markazi > div > p")) #attention, les 07ème ne passent pas, méthode à perfectionner Max
            hashed_property[:description] = access_xml_text(html, "div.wpb_wrapper > p").tr("\n\r\t", "").strip
            hashed_property[:agency_name] = "Immopolis"
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.image_carousel > figure > div.vc_single_image-wrapper > img.vc_single_image-img.attachment-full", "src")
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
