class ScraperConnexionImmobilier < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.connexion-immobilier.com/achat-vente-immobilier-acheter-paris/resultats-annonces-achat"
    @source = "Connexion Immobilier"
    @main_page_cls = "div.prdlst"
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
        hashed_property[:link] = regex_gen(access_xml_link(item, "a.gp", "href")[0], "(&url=http)(.)*").gsub("&url=", "")
        hashed_property[:surface] = access_xml_text(item, ".surface>span").to_int_scrp
        hashed_property[:area] = access_xml_text(item, ".city > nobr").to_int_scrp.to_s.district_generator
        hashed_property[:rooms_number] = access_xml_text(item, ".rooms").to_int_scrp
        hashed_property[:price] = access_xml_text(item, ".price").to_s.force_encoding("UTF-8").split("€")[0].to_int_scrp
        if go_to_prop?(hashed_property, 7)
          html = fetch_static_page(hashed_property[:link])
          hashed_property[:description] = access_xml_text(html, "div.desc").strip.gsub(/[^[:print:]]/, "")
          !access_xml_text(item, ".bedrooms").empty? ? hashed_property[:bedrooms_number] = access_xml_text(item, ".bedrooms").to_int_scrp : nil
          access_xml_text(item, ".floor").gsub(/[^[:print:]]/, "").include?("RDC") ? hashed_property[:floor] = 0 : hashed_property[:floor] = access_xml_text(item, ".floor").to_int_scrp
          (access_xml_link(item, ".floor", "class")[0].include?("nolift") || access_xml_link(item, ".floor", "class")[0].include?("floorrdc")) ? hashed_property[:has_elevator] = false : hashed_property[:has_elevator] = true
          hashed_property[:provider] = "Agence"
          hashed_property[:source] = @source
          hashed_property[:agency_name] = access_xml_text(html, "#detformcall > div.txt > p.name")
          hashed_property[:contact_number] = access_xml_text(html, "#detformcall > div.txt > p.desktoponly.tel").gsub(" ", "")
          hashed_property[:subway_ids] = perform_subway_regex(hashed_property[:description])
          imgs = access_xml_link(html, '[itemprop="image"]', "src")
          hashed_property[:images] = []
          imgs.each do |img|
            hashed_property[:images].push(img) if !img.nil?
          end
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
