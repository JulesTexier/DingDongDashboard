class Independant::ScraperAabiImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "AABI Immobilier"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          next if access_xml_text(item, "span.price").include?("Prix sur demande")
          hashed_property = {}
          hashed_property[:link] = "https://www.aabimmobilier.com" + access_xml_link(item, "a", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "li.area").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "h3"))
          hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "p"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:rooms_number] = regex_gen(access_xml_text(html, "div.summary.details.clearfix").remove_acc_scrp, '(piece(s?))(.?)(\d+)(.?)(piece(s?))').to_int_scrp
            hashed_property[:description] = access_xml_text(html, "#description").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+336 95 52 48 31"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.picture", "src").select { |img| !img.include?("templates/Altera/snpi-logo.svg") }
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
