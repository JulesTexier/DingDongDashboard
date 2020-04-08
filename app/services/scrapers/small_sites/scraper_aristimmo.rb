require "typhoeus"

class SmallSites::ScraperAristimmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :http_request

  def initialize
    @url = "https://www.aristimmo.com/vente-75/1"
    @source = "Aristimmo"
    @main_page_cls = "li.panelBien"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @http_request = [{}, { "Sort[field]" => "dateenr", "Sort[order]" => "ASC" }]
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.aristimmo.com" + access_xml_link(item, ".bienTitle > h1 > a", "href")[0].to_s
        title = access_xml_text(item, ".bienTitle > h2").strip.gsub(" ", "").gsub(/[^[:print:]]/, "")
        hashed_property[:surface] = regex_gen(title, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(title)
        hashed_property[:rooms_number] = regex_gen(title, '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:price] = item.at("//span[@itemprop = 'price']").children[0].to_s.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          details = access_xml_text(html, "#dataContent").strip.gsub(" ", "").gsub(/[^[:print:]]/, "")
          hashed_property[:bedrooms_number] = regex_gen(details, '(chambre\(s\))(\d+)').to_int_scrp
          hashed_property[:description] = html.at("//p[@itemprop = 'description']").children[0].to_s
          hashed_property[:flat_type] = get_type_flat(title)
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = regex_gen(details, '(Etage)(\d+)').to_int_scrp
          hashed_property[:has_elevator] = nil
          elevator_raw = regex_gen(details, "Ascenseur(OUI|NON)").gsub("Ascenseur", "")
          elevator_raw == "OUI" ? hashed_property[:has_elevator] = true : nil
          elevator_raw == "NON" ? hashed_property[:has_elevator] = false : nil
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          raw_images = access_xml_link(html, ".imageGallery> li > img", "src")
          raw_images.each do |img|
            hashed_property[:images].push("https:" + img)
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
