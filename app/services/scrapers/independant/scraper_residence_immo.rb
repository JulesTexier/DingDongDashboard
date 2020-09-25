class Independant::ScraperResidenceImmo < Scraper
  attr_accessor :properties, :source, :params

  def initialize(sp_id = nil)
    @source = "Residence Immobilier"
    @params = fetch_init_params(@source, sp_id)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "a.link-annonce-image", "href")[0]
          hashed_property[:rooms_number] = access_xml_text(item, 'span[itemprop="numberOfRooms"]').to_int_scrp
          hashed_property[:surface] = access_xml_text(item, 'span[itemprop="floorSize"]').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.ville"), args.zone)
          hashed_property[:price] = access_xml_text(item, "span.prix").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, 'span[itemprop="name"]'))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.col.pr-xl-5 > p").tr("\n", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "img.photo-miniature", "src")
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
