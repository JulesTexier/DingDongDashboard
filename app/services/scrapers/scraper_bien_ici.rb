class ScraperBienIci < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr, :wait, :click_args

  def initialize
    @url = "https://www.bienici.com/recherche/achat/paris-75000?tri=publication-desc"
    @source = "BienIci"
    @main_page_cls = "div.detailsContainer"
    @type = "Dynamic"
    @waiting_cls = "detailsContainer"
    @multi_page = false
    @page_nbr = 1
    @properties = []
    @wait = 0
  end

  def launch(limit = nil)
    i = 0
    fetch_main_page(self).each do |item|
      begin
        hashed_property = {}
        hashed_property[:link] = "https://www.bienici.com" + access_xml_link(item, "a.detailedSheetLink", "href")[0].to_s
        hashed_property[:surface] = regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), '(\d+(,?)(\d)?)(.)m').to_int_scrp
        hashed_property[:area] = regex_gen(access_xml_text(item, "div.cityAndDistrict"), '(75)$*\d+{3}')
        hashed_property[:rooms_number] = regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), '(\d+)(.?)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:rooms_number] = 1 if regex_gen(access_xml_array_to_text(item, "span.generatedTitleWithHighlight"), "(S|s)tudio") == "Studio"
        hashed_property[:price] = regex_gen(access_xml_text(item, "span.thePrice"), '(\d)(.*)(€)').to_int_scrp
        if go_to_prop?(hashed_property, 7) && !hashed_property[:link].match(/(depuis-mise-en-avant=oui|visiteonline-)/i).is_a?(MatchData)
          html = fetch_dynamic_page(hashed_property[:link], "detailedSheetContainer", 0)
          hashed_property[:bedrooms_number] = regex_gen(access_xml_array_to_text(html, "div.allDetails").specific_trim_scrp("\n\r\t"), '(\d+)(.?)(chambre(s?))').to_int_scrp
          hashed_property[:description] = access_xml_text(html, "div.descriptionContent").specific_trim_scrp("\n\t\r").strip
          hashed_property[:flat_type] = regex_gen(access_xml_text(html, "div.titleInside h1"), "Achat(.)(\w+)").gsub("Achat ", "").capitalize
          hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
          hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(html, "div.w > img", "src")
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
          i += 1
          break if i == limit
        end
      rescue StandardError => e
        puts "\nError for #{@source}, skip this one."
        puts "It could be a bad link or a bad xml extraction.\n\n"
        puts e.message
        puts e.backtrace
        next
      end
    end
    return @properties
  end
end
