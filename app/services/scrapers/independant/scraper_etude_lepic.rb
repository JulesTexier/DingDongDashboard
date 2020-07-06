class Independant::ScraperEtudeLepic < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Etude Lepic"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = "https://www.etudelepic.fr" + access_xml_link(item, "a", "href")[0]
          hashed_property[:surface] = access_xml_text(item, "li.surface > div.ctn-li > span.txt").to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.address"))
          hashed_property[:rooms_number] = access_xml_text(item, "li.pieces > div.ctn-li > span.txt").to_int_scrp
          hashed_property[:bedrooms_number] = access_xml_text(item, "li.chambres > div.ctn-li > span.txt").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "span.type"))
          if go_to_prop?(hashed_property, 7)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.description").tr("\n\t\r", "").strip
            hashed_property[:provider] = "Agence"
            hashed_property[:contact_number] = "+33142581111"
            hashed_property[:source] = @source
            hashed_property[:images] = []
            access_xml_array_to_text(html, "script").each_line do |line|
              hashed_property[:images].push("https://www.etudelepic.fr" + line.split('src:"')[1].split('", alt:')[0]) if line.include?('slides.push({ src:"/datas/biens')
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
