class ScraperMorissImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.morissimmobilier.com/recherche-immobiliere-avancee/page/[[PAGE_NUMBER]]/?advanced_city=&surface-min=0&nb-chambres-min=0&budget-max=10000000"
    @source = "MorissImmobilier"
    @main_page_cls = "div.property_listing"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = true
    @page_nbr = 5
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      if access_xml_text(item, "div.ribbon-inside") == "Disponible"
        begin
          hashed_property = {}
          hashed_property[:link] = access_xml_link(item, "div.item > a", "href")[0].to_s
          hashed_property[:surface] = regex_gen(access_xml_text(item, "div.infosize_unit_type4 > span"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
          hashed_property[:area] = regex_gen(access_xml_text(item, "div.property_address_type4 > span > a"),'(\d+){2}').district_generator
          hashed_property[:rooms_number] = access_xml_text(item, "div.inforoom_unit_type4 > span").to_int_scrp
          hashed_property[:price] = access_xml_text(item, "div.listing_unit_price_wrapper").to_int_scrp
          hashed_property[:flat_type] = regex_gen(access_xml_text(item, "h4 > a"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
          if is_property_clean(hashed_property)
            html = fetch_static_page(hashed_property[:link])
            hashed_property[:description] = access_xml_text(html, "div.wpestate_property_description > p").specific_trim_scrp("\n").strip
            hashed_property[:agency_name] = access_xml_text(html, "div.agent_unit > div > h4 > a")
            hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
            hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
            hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
            hashed_property[:provider] = "Agence"
            hashed_property[:source] = @source
            hashed_property[:images] = access_xml_link(html, "div.gallery_wrapper > div", "style")
            hashed_property[:images].each do |image_url|
              image_url.gsub!("background-image:url(","").gsub!(")","")
            end
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert_v2(hashed_property)
            i += 1
            break if i == limit
            puts JSON.pretty_generate(hashed_property)
          end
        rescue StandardError => e
          puts "\nError for #{@source}, skip this one."
          puts "It could be a bad link or a bad xml extraction.\n\n"
          puts e.message
          puts e.backtrace
          next
        end
      end
    end
    return @properties
  end
end
