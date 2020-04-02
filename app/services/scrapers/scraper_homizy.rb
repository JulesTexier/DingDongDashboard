class ScraperHomizy < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.homizy-immobilier.com/a-vendre/1"
    @source = "Homizy"
    @main_page_cls = "ul.listingUL > li"
    @type = "Static"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @click_args = [{ element: "div", values: { id: "a_filter_order" } }, { element: "li", values: { text: "Le plus récent d'abord" } }]

    @properties = []

    @waiting_cls = "carousel-inner"
    @multi_page = true
    @page_nbr = 13
    @wait = 0
    @click_args = [{ element: "div", values: { id: "a_filter_order" } }, { element: "li", values: { text: "Le plus récent d'abord" } }]
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.homizy-immobilier.com" + access_xml_link(item, "article", "onclick")[0].to_s.gsub("location.href='","").gsub("'","")
        hashed_property[:surface] = regex_gen(access_xml_text(item, "header.lstbody > h2"), '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
        hashed_property[:area] = "75001"
        # regex_gen(access_xml_text(item, "div.ville > span"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "header.lstbody > h2").tr("\r\n\s\t", "").strip, '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:price] = access_xml_text(item, "div.left-caption > span:nth-child(2) > span:nth-child(1)").to_int_scrp
        hashed_property[:flat_type] = regex_gen(access_xml_text(item, "header.lstbody > h2"), "((a|A)ppartement|(A|a)ppartements|(S|s)tudio|(S|s)tudette|(C|c)hambre|(M|m)aison)")
        if is_property_clean(hashed_property)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "article.elementDt > p").specific_trim_scrp("\n").strip
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "li > img", "src")
          hashed_property[:images].collect!{ |img| "https:" + img}
          @properties.push(hashed_property) ##testing purpose
          # enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      puts JSON.pretty_generate(hashed_property)
      rescue StandardError => e
        puts e.backtrace
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        next
      end
    end
    return @properties
  end
end
