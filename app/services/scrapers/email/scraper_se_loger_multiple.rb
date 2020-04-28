class Email::ScraperSeLogerMultiple < Scraper
  attr_accessor :html_content, :properties, :source, :main_page_cls

  def initialize(html_content)
    @html_content = html_content
    @source = "SeLoger"
    @main_page_cls = "td.two-column"
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    html = Nokogiri::HTML(html_content)
    items = access_xml_raw(html, @main_page_cls)
    items.each do |item|
      begin
        content = access_xml_text(item, "table.contents").gsub(" ", "").gsub(/[^[:print:]]/, "")
        hashed_property = {}
        hashed_property[:price] = regex_gen(content, '(\d)(.*)(€)').to_int_scrp
        hashed_property[:rooms_number] = regex_gen(content, '(•)(\d+)(pi(è|e)ce(s?))').to_int_scrp
        hashed_property[:area] = perform_district_regex(content)
        hashed_property[:surface] = regex_gen(content, '(\d){1,}(m)').to_float_to_int_scrp
        next if access_xml_link(item, 'a[_label="CTA"]', "href")[0].include?("www.bellesdemeures.com")
        hashed_property[:link] = "https://" + regex_gen(access_xml_link(item, 'a[_label="CTA"]', "href")[0], "(www.seloger.com)(.){1,}(htm)")
        hashed_property[:images] = access_xml_link(item, "span > img", "src").map { |img| img.gsub("300x225", "600x450") }
        hashed_property[:description] = ""
        hashed_property[:subway_ids] = []
        hashed_property[:floor] = nil
        hashed_property[:flat_type] = get_type_flat(content)
        hashed_property[:provider] = "Agence"
        hashed_property[:source] = @source
        hashed_property[:has_elevator] = nil
        if go_to_prop?(hashed_property, 7)
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert_v2(hashed_property)
        end
      rescue StandardError => e
        error_outputs(e, @source)
        next
      end
    end
    return @properties
  end
end
