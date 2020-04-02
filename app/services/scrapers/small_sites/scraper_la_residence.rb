class SmallSites::ScraperLaResidence < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.laresidence.fr/nos-annonces?Etats=Bac&CodesVille=1862,21759,650,554,21952,682,493,21996,654,680,21967,21787,661,21660,21756,22022,573,21861,45938,45937&CodesType=20,1&autosave=true"
    @source = "La Résidence"
    @main_page_cls = "div.vignetteBienListing"
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
        hashed_property[:link] = "https://www.laresidence.fr/" + access_xml_link(item, "div:first-child > a", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, ".vignetteBienTitre > h2"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, ".vignetteBienTitre > h2").area_translator_scrp, '(75)$*\d+{3}')
        hashed_property[:bedrooms_number] = regex_gen(access_xml_text(item, ".vignetteBienTexte"), '(\d+)(.?)(chambre(s?))').to_float_to_int_scrp
        hashed_property[:rooms_number] = hashed_property[:bedrooms_number] + 1
        hashed_property[:price] = access_xml_text(item, ".vignetteBienPrixFAI").to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:rooms_number] = regex_gen(access_xml_text(html, ".ficheAffaireWrapper> h1").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_float_to_int_scrp
          if hashed_property[:rooms_number] == 1
            hashed_property[:bedrooms_number] = 0
          end
          hashed_property[:description] = access_xml_text(html, "#descriptif_anchor > p").strip.gsub(/[^[:print:]]/, "")
          hashed_property[:flat_type] = get_type_flat(access_xml_text(html, ".ficheAffaireWrapper> h1").strip)
          hashed_property[:agency_name] = @source
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, ".swiper-slide3 > a > img", "src")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
