class Independant::ScraperParisVente < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.parisvente.com/pv_liste.pl?ACTION=CONSULTER;FROM=LISTE;PAR_PAGE=20;PAR_PAGE3=selected;ISMOBILE=non;ISMOBILE_OU_TABLETTE=non;localisation=75015%2C75006%2C75007%2C75014%2C75013%2C75005%2C75012%2C75004%2C75001%2C75008%2C75016%2C75017%2C75018%2C75009%2C75010%2C75002%2C75003%2C75011%2C75020%2C75019;localisationTitle=75015%2C%2075006%2C%2075007%2C%2075014%2C%2075013%2C%2075005%2C%2075012%2C%2075004%2C%2075001%2C%2075008%2C%2075016%2C%2075017%2C%2075018%2C%2075009%2C%2075010%2C%2075002%2C%2075003%2C%2075011%2C%2075020%2C%2075019;localisationDatastate=75015---75015%2C75006---75006%2C75007---75007%2C75014---75014%2C75013---75013%2C75005---75005%2C75012---75012%2C75004---75004%2C75001---75001%2C75008---75008%2C75016---75016%2C75017---75017%2C75018---75018%2C75009---75009%2C75010---75010%2C75002---75002%2C75003---75003%2C75011---75011%2C75020---75020%2C75019---75019;TYPE_BIEN=appartement;TYPE_BIEN=maison%20de%20ville;PRIX_MIN=0;PRIX_MAX=10000000;SURFACE_MIN=0;SURFACE_MAX=1000;submit=Rechercher;NUM_PAGE=1"
    @source = "Paris Vente"
    @main_page_cls = "div.propItem"
    @type = "Static"
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
        hashed_property[:link] = "https://www.parisvente.com/pv_liste.pl" + access_xml_link(item, "h2 > a", "href")[0]
        hashed_property[:surface] = regex_gen(access_xml_text(item, "h2 > a").tr("\t\n", ""), '(\d+(.?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = perform_district_regex(access_xml_text(item, "h3"))
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "h2 > a").remove_acc_scrp, '(\d+)(.?)(piece(s?))').to_int_scrp
        hashed_property[:rooms_number] = 1 if access_xml_text(item, "h2 > a").match(/(studio)/i).is_a?(MatchData)
        hashed_property[:price] = access_xml_text(item, "a.propItemPrice").to_int_scrp
        hashed_property[:images] = access_xml_link(item, "a.gallery-thumb", "href").map { |img| "https://www.parisvente.com/" + img }
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "p#propDescriptif").tr("\n\t\r", "").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:contact_number] = "+331 43 38 08 15"
          hashed_property[:source] = @source
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
