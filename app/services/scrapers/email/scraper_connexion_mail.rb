class Email::ScraperConnexionMail < Scraper
  attr_accessor :html_content, :properties, :source, :params

  def initialize(html_content)
    @html_content = html_content
    @source = "Connexion Immobilier"
    @params = fetch_init_params(@source, nil, is_mail_alert = true)
    @properties = []
  end

  def launch(limit = nil)
    email_link = Nokogiri::HTML.parse(@html_content)
    link = access_xml_link(email_link, "a", "href")[0]
    if !link.nil? && !self.params.empty?
      html = fetch_static_page(link)
      access_xml_raw(html, "body").each do |item|
        begin
          hashed_property = {}
          hashed_property[:link] = link
          hashed_property[:price] = regex_gen(access_xml_text(item, "article > h2 > span"), '(\d)(.*)').to_int_scrp
          hashed_property[:rooms_number] = regex_gen(access_xml_text(item, "li.mdi-hotel"), '(\d)(.*)').to_float_to_int_scrp
          hashed_property[:surface] = regex_gen(access_xml_text(item, "li.mdi-arrow-expand-all"), '(\d+(.?)(\d*))(.)(m²)').to_float_to_int_scrp
          hashed_property[:area] = perform_district_regex(access_xml_text(item, "article > h2"))
          hashed_property[:description] = access_xml_text(item, "article > p").strip
          hashed_property[:flat_type] = "N/C"
          hashed_property[:agency_name] = "Connexion"
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:images] = access_xml_link(item, "section.pictures > figure > a", "href")
          hashed_property[:reference] = "Connexion Immobilier Mail"
          if go_to_prop?(hashed_property, 7)
            @properties.push(hashed_property) ##testing purpose
            enrich_then_insert(hashed_property)
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
