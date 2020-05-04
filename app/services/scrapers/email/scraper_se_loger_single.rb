class Email::ScraperSeLogerSingle < Scraper
  attr_accessor :html_content, :properties, :source

  def initialize(html_content)
    @html_content = html_content
    @source = "SeLoger"
    @main_page_cls = "li.property.initial"
    @properties = []
  end

  def launch(limit = nil)
    begin
      item = Nokogiri::HTML(html_content)
      hashed_property = {}
      title = access_xml_text(item, "body > center > div > div")
      hashed_property[:price] = regex_gen(title, '(\-)(.*)(\d)(.*)(\d)(.*)(€)').to_int_scrp
      hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "td.col100:nth-child(1)").gsub(" ", "").gsub(/[^[:print:]]/, "").remove_acc_scrp, '(\d+)(piece(s?))').to_int_scrp
      hashed_property[:area] = perform_district_regex(title)
      hashed_property[:surface] = regex_gen(title, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
      hashed_property[:link] = "https://" + regex_gen(access_xml_link(item, 'a[_label="cta"]', "href")[0], "(www.seloger.com)(.){1,}(htm)")
      hashed_property[:images] = access_xml_link(item, 'td.contents > a[_label="image"] > img', "src")
      hashed_property[:description] = access_xml_text(item, 'a[ _label="description"]').tr("\n\r", "").strip
      hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
      hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
      hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
      hashed_property[:flat_type] = get_type_flat(title)
      hashed_property[:provider] = "Agence"
      hashed_property[:source] = @source
      if go_to_prop?(hashed_property, 30)
        @properties.push(hashed_property) ##testing purpose
        enrich_then_insert_v2(hashed_property)
      end
    rescue StandardError => e
      error_outputs(e, @source)
    end
    return @properties
  end
end
