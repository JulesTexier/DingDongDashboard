class Independant::ScraperParisVente < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "Paris Vente"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      fetch_main_page(args).each do |item|
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
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
