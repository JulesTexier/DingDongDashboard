class Email::ScraperSeLoger < Scraper
  attr_accessor :html_content, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize(html_content)
    @html_content = html_content
    @source = "SeLoger"
    @main_page_cls = "li.property.initial"
    @type = "Captcha"
    @waiting_cls = nil
    @multi_page = true
    @page_nbr = 2
    @properties = []
  end

  def launch(limit = nil)
    begin
    item = Nokogiri::HTML(html_content)
    hashed_property = {}
    title = access_xml_text(item,'body > center>div > div')
    hashed_property[:price] = regex_gen(title, '(\-)(.*)(\d)(.*)(\d)(.*)(€)').to_int_scrp
    hashed_property[:rooms_number] = regex_gen(access_xml_text(item,'td.col100:nth-child(1)').gsub(" ", "").gsub(/[^[:print:]]/, ""), '(\d+)(pi(è|e)ce(s?))').to_float_to_int_scrp 
    hashed_property[:area] = perform_district_regex(title) 
    hashed_property[:surface] = regex_gen(title, '(\d+(,?)(\d*))(.)(m)').to_float_to_int_scrp
    raw_link = access_xml_link(item, 'a[_label="cta"]', 'href')[0]
    hashed_property[:link] = "https://" + regex_gen(raw_link, '(www.seloger.com)(.){1,}(htm)')
    @properties = []
    html = fetch_static_page(hashed_property[:link])
    # html = Nokogiri::HTML(open("sl.html")) #test purpose : avoid to burn BEE credits ...
    if go_to_prop?(hashed_property, 7)
    hashed_property[:bedrooms_number] = regex_gen(access_xml_text(html,'.Summarystyled__TagsWrapper-tzuaot-18').gsub(" ", "").gsub(/[^[:print:]]/, ""), '(\d+)(chambre(s?))').to_int_scrp
      hashed_property[:flat_type] = get_type_flat(title)
      hashed_property[:description] = access_xml_text(html, '#showcase-description > div:nth-child(2) > div > div > div > div > p').strip
      hashed_property[:floor] = perform_floor_regex(access_xml_text(html, '#showcase-description > div:nth-child(3) > div > div > div:nth-child(1) > div'))
      hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
      hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
      hashed_property[:provider] = "Agence"
      hashed_property[:agency_name] = access_xml_text(html, ' div.LightSummary__Container-f6k8ax-0.hxnYKw > div > h3')
      hashed_property[:source] = @source
      hashed_property[:images] =  access_xml_link(html, '.Slide__ShowcaseMediaSlide-sc-8kj5lh-0 > div', 'data-background').select { |img| !img.nil? }
    byebug
      @properties.push(hashed_property) ##testing purpose
      enrich_then_insert_v2(hashed_property)
    end
    rescue StandardError => e
      error_outputs(e, @source)
      next
    end
    return @properties
  end
end
