class ScraperLuxResidence < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.lux-residence.com/fr/annonces/vente/immobilier-prestige-PARIS.php?currency=EUR&sort=date_desc"
    @source = "Lux Residence"
    @main_page_cls = "#prod-list > div > div > div.row"
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
        hashed_property[:link] = access_xml_link(item, "a", "href")[2].to_s
        hashed_property[:price] = regex_gen(access_xml_text(item, ".price"), '(\d)(.*)').to_int_scrp
        sub_item = access_xml_array_to_text(item, "div.prod-r.prod-desc")
        hashed_property[:area] = regex_gen(sub_item, '(PARIS)(.?)(\d+)').tr("^0-9", "").district_generator
        hashed_property[:surface] = regex_gen(sub_item, '(\d+(.?)(\d*))(.)(m2)').to_float_to_int_scrp
        hashed_property[:rooms_number] = regex_gen(sub_item, '(\d+)(.?)(Pi(è|e)ce(s?))').to_float_to_int_scrp
        hashed_property[:flat_type] = regex_gen(sub_item, "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if go_to_prop?(hashed_property, 7) # Just to check but I don't load HTML show
          hashed_property[:description] = access_xml_text(item, "p.description").strip
          hashed_property[:agency_name] = access_xml_text(item, "h4").gsub("Agence : ", "")
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(item, "img", "src")
          hashed_property[:images].delete_if { |img| img == nil }
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
