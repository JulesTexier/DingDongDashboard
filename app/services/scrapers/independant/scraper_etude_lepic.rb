class Independant::ScraperEtudeLepic < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.etudelepic.fr/vente-appartement-paris/tri=id&ordre=DESC"
    @source = "Etude Lepic"
    @main_page_cls = "article.annonce_listing"
    @scraper_type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @wait = 0
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.etudelepic.fr" + access_xml_link(item, "a", "href")[0]
        hashed_property[:surface] = access_xml_text(item, "li.surface > div.ctn-li > span.txt").to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "span.address"))
        hashed_property[:rooms_number] = access_xml_text(item, "li.pieces > div.ctn-li > span.txt").to_int_scrp
        hashed_property[:bedrooms_number] = access_xml_text(item, "li.chambres > div.ctn-li > span.txt").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.description").tr("\n\t\r", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+33142581111"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          access_xml_array_to_text(html, "script").each_line do |line|
            hashed_property[:images].push("https://www.etudelepic.fr" + line.split('src:"')[1].split('", alt:')[0]) if line.include?('slides.push({ src:"/datas/biens')
          end
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
