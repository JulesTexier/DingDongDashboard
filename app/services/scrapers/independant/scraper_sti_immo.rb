class Independant::ScraperStiImmo < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "http://www.sti-immo.com/recherche/"
    @source = "STI Immo"
    @main_page_cls = "article"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
    # @http_type = "post"
    # @http_request = [{}, "data%5BSearch%5D%5Boffredem%5D=0&data%5BSearch%5D%5Bidtype%5D%5B%5D=1&data%5BSearch%5D%5Bidtype%5D%5B%5D=2&data%5BSearch%5D%5Bidville%5D=&data%5BSearch%5D%5Bidville%5D=&data%5BSearch%5D%5Bprixmax%5D=&data%5BSearch%5D%5Bpiecesmin%5D=&data%5BSearch%5D%5BNO_DOSSIER%5D=&data%5BSearch%5D%5Bdistance_idvillecode%5D=&data%5BSearch%5D%5Bprixmin%5D=&data%5BSearch%5D%5Bsurfmin%5D="]
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        clean_title = access_xml_text(item, "p[itemprop='description']").strip.gsub(/[^[:print:]]/, "").gsub(' ','').remove_acc_scrp
        is_paris = clean_title.match(/paris/i).is_a?(MatchData)
        next if !is_paris
        next unless (clean_title.include?("appartement") || clean_title.include?("studio") )
        hashed_property[:area] = "750" + regex_gen(clean_title, 'paris(\d)*').gsub('paris','')
        hashed_property[:link] = "http://www.sti-immo.com" + access_xml_link(item, "a:nth-child(1)", "href")[0].to_s
        hashed_property[:price] = access_xml_text(item, "span[itemprop='price']").to_int_scrp
        hashed_property[:rooms_number] = regex_gen(clean_title, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:surface] = regex_gen(clean_title, '(\d+(,?)(\d*))(.)(m)').to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.description").strip

          details = access_xml_text(html, "#infos").strip.gsub(/[^[:print:]]/, "").downcase.gsub(' ','').remove_acc_scrp
          if details.match(/etage(\d)*/i).is_a?(MatchData) 
            hashed_property[:has_elevator] = regex_gen(details, 'etage(\d)*').to_int_scrp
          else 
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          end
          if details.match(/ascenseur(oui|non)/i).is_a?(MatchData) 
            regex_gen(details, 'ascenseur(oui|non)').include?('oui') ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = false
          else 
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          end

          hashed_property[:bedrooms_number] = access_xml_text(html, ".little-infos > div:nth-child(3) > div:nth-child(2) > h5:nth-child(1)").to_int_scrp
          hashed_property[:flat_type] = get_type_flat(clean_title)
          hashed_property[:agency_name] = access_xml_text(html, '.agence > div >  h5')
          hashed_property[:contact_number] = access_xml_text(html, 'span.telagence').gsub(' ','').gsub(/[^[:print:]]/, "")
          hashed_property[:subway_ids] = perform_subway_regex(access_xml_text(html, 'h1[itemprop="name"]') + hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".imgBien", "src")
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
