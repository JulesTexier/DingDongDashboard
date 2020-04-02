class ScraperVillageBleu < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr
  def initialize
    @url = "http://www.villagebleu.com/recherche,incl_recherche_mobilefirst_ajax.htm?idqfix=1&annlistepg=1&lang=fr&idtt=2&idtypebien=1&ci=750056&tri=d_dt_crea"
    @source = "Village Bleu"
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
        hashed_property[:link] = access_xml_link(item, 'a', 'href')[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_text(item, '.annonce-surface'), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = regex_gen(hashed_property[:link], '([0-9]){1,}eme').to_int_scrp.to_s.district_generator
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, '.annonce-pieces'), '([0-9]){1,}').to_float_to_int_scrp
        hashed_property[:price] = access_xml_text(item, '.annonce-prix').strip.to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p.detail-desc-txt").strip
          details = access_xml_text(html, '.detail-sign').strip.gsub(' ','').gsub(/[^[:print:]]/, "").downcase.remove_acc_scrp
          hashed_property[:bedrooms_number] = regex_gen(details, 'chambre(s){0,}(\d){1,}').to_int_scrp
          hashed_property[:flat_type] = "Appartement"
          floor = regex_gen(details, 'etage{0,}((\d){1,}|rdc)').gsub('etage','')
          floor == "rdc" ? hashed_property[:floor] = 0 : hashed_property[:floor] = floor.to_int_scrp
          elevator = regex_gen(details, 'ascenseuroui').gsub('ascenseur','')
          elevator == "oui" ? hashed_property[:has_elevator] = true : hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = []
          images = access_xml_link(html, '.detail-galerie-item', 'style')
          images.each do |img|
            hashed_property[:images].push(regex_gen(img, 'https(.)*.jpg'))   
          end
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