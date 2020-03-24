class ScraperLaforet < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.laforet.com/acheter/rechercher?filter%5Bcities%5D=75&filter%5Btypes%5D=house%2Capartment"
    @source = "Laforet"
    @main_page_cls = "div.property-card"
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
        hashed_property[:link] = "https://www.laforet.com" + access_xml_link(item, "a.property-card__link", "href")[0].to_s
        # puts access_xml_array_to_text(item, "div.property-card__infos")
        puts item.text
        hashed_property[:link].match('(paris-(\d+))').is_a?(MatchData) ? hashed_property[:area] = regex_gen(hashed_property[:link], '(paris-(\d+))').tr("^0-9", "").district_generator : hashed_property[:area] = regex_gen(item.text, "(Paris(.?)(\d+))").tr("^0-9", "").district_generator
        hashed_property[:area] = regex_gen(item.text, '(PARIS (\d+))').tr("^0-9", "").district_generator
        hashed_property[:surface] = regex_gen(item.text, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:rooms_number] = regex_gen(item.text.force_encoding("UTF-8"), '(\d+)(.?)(piÃ¨ce(s?))').to_int_scrp
        hashed_property[:price] = regex_gen(item.text.tr("â¬", "€"), '(\d)(.*)(€)').to_int_scrp
        # hashed_property[:flat_type] = regex_gen(access_xml_text(item, "div.vertical-align > h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        # if is_property_clean(hashed_property)
        #   html = fetch_static_page(hashed_property[:link])
        #   hashed_property[:description] = access_xml_text(html, "p.read-more").specific_trim_scrp("\n").strip
        #   hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
        #   hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
        #   hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
        #   hashed_property[:provider] = "Agence"
        #   hashed_property[:source] = @source
        #   hashed_property[:images] = ["http://www.callimmo.fr" + access_xml_link(html, "li.clearing-featured-img.small-12.margin-no > div > a", "href")[0].to_s]
        #   @properties.push(hashed_property) ##testing purpose
        #   enrich_then_insert_v2(hashed_property)
        #   i += 1
        #   break if i == limit
        # end
        puts hashed_property
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        puts e.message
        next
      end
    end
    return @properties
  end
end
