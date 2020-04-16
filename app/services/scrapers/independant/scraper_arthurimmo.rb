class Independant::ScraperArthurimmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.paris20-arthurimmo.com/immobilier/pays/achat/france.htm#ci=750056&idqfix=1&idtt=2&lang=fr&tri=d_dt_crea"
    @source = "Arthurimmo"
    @main_page_cls = "div.annonce"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a", 'href')[0]
        hashed_property[:surface] = access_xml_text(item, "span.annonce-surface").to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h4.annonce-ville").gsub(/[^[:print:]]/, ""))
        hashed_property[:rooms_number] = access_xml_text(item, "span.annonce-pieces").to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.annonce-prix").strip.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html,'.detail-surf').gsub(" ","").gsub(/[^[:print:]]/, ""), '(\d)*chambre').to_int_scrp
          hashed_property[:flat_type] = get_type_flat(access_xml_text(html, 'h1[itemprop="name"]'))
          hashed_property[:description] = access_xml_text(html, ".detail-desc-txt").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, ".localisation"))
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(html,'div[itemprop="name"]')
          hashed_property[:contact_number] = access_xml_text(html, '#numero-telephonez-nous-detail').gsub(" ","").gsub(/[^[:print:]]/, "")[0..9]
          hashed_property[:images] = []
          raw_images = access_xml_link(html, "div.detail-galerie-item", "style")
          raw_images.each do |img|
              hashed_property[:images].push(img.gsub("background-image:url(", "").gsub(");","")) if !img.nil?
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
