class Premium::ScraperLeBonCoin < Scraper
  attr_accessor :url, :properties, :source, :main_page_cls, :type, :waiting_cls, :multi_page, :page_nbr

  def initialize
    @url = "https://www.leboncoin.fr/recherche/?category=9&locations=Paris__48.85790400439863_2.358842071208555_10000&immo_sell_type=old,new&real_estate_type=1,2&price=50000-max"
    @source = "LeBonCoin"
    @main_page_cls = "body"
    @type = "Captcha"
    @waiting_cls = nil
    @multi_page = false
    @page_nbr = 1
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    xml = fetch_main_page(self)
    if !xml[0].to_s.strip.empty?
      json = extract_json(xml)
      hashed_properties = []
      if !json.nil?
        json["data"]["ads"].each do |item|
          begin
            unless Rails.env.test?
              ## Some tape to prevent LBC lack of properties and random old properties showing up on main page
              ## wrapped it in a condition for test env, otherwise every fixtures will be outdated in two days
              next if Time.parse(item["first_publication_date"]) < Time.now - 2.days
            end
            hashed_property = extract_each_flat(item)
            property_checker_hash = {}
            property_checker_hash[:rooms_number] = hashed_property[:rooms_number]
            property_checker_hash[:surface] = hashed_property[:surface]
            property_checker_hash[:price] = hashed_property[:price]
            property_checker_hash[:area] = hashed_property[:area]
            property_checker_hash[:link] = hashed_property[:link]
            if go_to_prop?(property_checker_hash, 7)
              @properties.push(hashed_property)
              enrich_then_insert_v2(hashed_property)
              i += 1
            end
            break if i == limit
          rescue StandardError => e
            error_outputs(e, @source)
            next
          end
        end
      else
        puts "Error Parsing JSON.\n\n"
      end
    else
      puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
    end
    return @properties
  end

  private

  def extract_json(html_array)
    json = []
    html_array.each do |html|
      begin
        first_part = html.text.split("window.__REDIAL_PROPS__ = [null,null,null,null,null,")[1]
        second_part = first_part.split("</script>")[0]
        json.push(JSON.parse(second_part.strip.chop))
      rescue JSON::ParserError => e
        puts "\nOupsiedoodle, #{@source} is giving us bad json."
        puts e.message
        next
      end
    end
    return json[0]
  end

  def extract_each_flat(item)
    flat_data = {}

    item["attributes"].each do |element|
      case element["key"]
      when "square"
        flat_data[:surface] = element["value"].to_i
      when "rooms"
        flat_data[:rooms_number] = element["value_label"].to_i
      when "real_estate_type"
        flat_data[:flat_type] = element["value_label"]
      end
    end

    !item["url"].nil? ? flat_data[:link] = item["url"].gsub(" u002F", "/").gsub("\s", "") : nil
    !item["body"].nil? ? flat_data[:description] = item["body"].tr("\n", "") : nil
    !item["location"]["zipcode"].nil? ? flat_data[:area] = item["location"]["zipcode"] : nil
    !item["price"].nil? ? flat_data[:price] = item["price"][0].to_i : nil

    !flat_data[:description].nil? ? flat_data[:floor] = perform_floor_regex(flat_data[:description]) : nil
    !flat_data[:description].nil? ? flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description]) : nil
    !flat_data[:description].nil? ? flat_data[:subway_ids] = perform_subway_regex(flat_data[:description]) : nil

    flat_data[:images] = []
    if !item["images"]["urls_large"].nil?
      flat_data[:images] = item["images"]["urls_large"]
    elsif !item["images"]["urls"].nil?
      flat_data[:images] = item["images"]["urls"]
    end

    flat_data[:source] = @source

    case item["owner"]["type"]
    when "pro"; flat_data[:provider] = "Agence"
    when "private"; flat_data[:provider] = "Particulier"
    else; flat_data[:provider] = "N/C"     end
    return flat_data
  end
end
