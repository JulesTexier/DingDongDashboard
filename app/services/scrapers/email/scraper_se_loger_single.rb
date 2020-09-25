class Email::ScraperSeLogerSingle < Scraper
  attr_accessor :html_content, :properties, :source, :params

  def initialize(html_content)
    @html_content = html_content
    @source = "SeLoger"
    @params = fetch_init_params(@source, nil, is_mail_alert = true)
    @properties = []
  end

  def launch(limit = nil)
    unless self.params.empty?
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
        hashed_property[:flat_type] = "N/C"
        hashed_property[:provider] = "Agence"
        hashed_property[:source] = @source
        hashed_property[:reference] = "SeLoger Mail"
        if go_to_prop?(hashed_property, 7)
          @properties.push(hashed_property) ##testing purpose
          enrich_then_insert(hashed_property)
        end
      rescue StandardError => e
        error_outputs(e, @source)
      end
    end
    return @properties
  end
end
