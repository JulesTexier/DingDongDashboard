class Independant::ScraperBpImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :scraper_type, :waiting_cls, :multi_page, :page_nbr, :http_request, :http_type

  def initialize
    @url = "https://www.bpimmo.com/recherche.php"
    @source = "Building Parners"
    @main_page_cls = "div.offre_bien"
    @scraper_type = "HTTPRequest"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @http_request = [{}, "ville%5B%5D=75001&ville%5B%5D=75002&ville%5B%5D=75003&ville%5B%5D=75004&ville%5B%5D=75005&ville%5B%5D=75006&ville%5B%5D=75007&ville%5B%5D=75008&ville%5B%5D=75009&ville%5B%5D=75010&ville%5B%5D=75011&ville%5B%5D=75012&ville%5B%5D=75013&ville%5B%5D=75014&ville%5B%5D=75010&ville%5B%5D=75015&ville%5B%5D=75016&ville%5B%5D=75017&ville%5B%5D=75018&ville%5B%5D=75019&ville%5B%5D=75020&budget=&rechercher=Rechercher"]
    @http_type = "post"
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = access_xml_link(item, "a.lien_offres", "href")[0].to_s
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "a.lien_offres > h2"))
        hashed_property[:price] = access_xml_text(item, "span.price").to_int_scrp
        hashed_property[:rooms_number] = regex_gen(hashed_property[:link], '(\d+)(.?)(pieces)').to_int_scrp
        hashed_property[:surface] = access_xml_text(item, "span.surface").to_float_to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.tn-detail-desc").strip
          hashed_property[:flat_type] = get_type_flat(access_xml_text(item, "a.lien_offres > h2"))
          details = access_xml_text(html, "div.elm").strip.gsub(/[^[:print:]]/, "").gsub(" ", "").remove_acc_scrp
          hashed_property[:floor] = regex_gen(details, 'etage:(\d)*').to_int_scrp
          if details.match(/ascenseur:(oui|non)/i).is_a?(MatchData)
            regex_gen(details, "ascenseur:(oui|non)").include?("oui") ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
          else
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          end
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.item >  img", "src")
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
