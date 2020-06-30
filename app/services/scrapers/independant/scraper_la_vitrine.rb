require "typhoeus"

class Independant::ScraperLaVitrine < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "La Vitrine Immo"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "http://www.lavitrine.immo" + access_xml_link(item, "a.btn-link", "href")[0]
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2.font-black.margin-no").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_raw(item, "h3.label.bg-dark.radius.white")[0].text.to_int_scrp
          hashed_property[:surface] = access_xml_raw(item, "h3.label.bg-dark.radius.white")[1].text.to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h2.font-black.margin-no"))
          hashed_property[:price] = access_xml_text(item, "h3.font-black.margin-no").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "h2.font-black.margin-no"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "p.read-more").tr("\r\n", "").strip
            hashed_property[:agency_name] = @source
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = access_xml_text(html, "li.phonenumber-2").tr("\t\n", "").convert_phone_nbr_scrp
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_link(html, "ul > li > a", "href").each do |img|
              hashed_property[:images].push("http://www.lavitrine.immo" + img) if !img.nil? && img.include?(".jpeg")
            end
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
