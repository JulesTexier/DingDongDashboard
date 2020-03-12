class ScraperLeBonCoin < Scraper
  attr_accessor :url, :properties, :source, :xml_first_page

  def initialize
    @url = "https://www.leboncoin.fr/recherche/?category=9&locations=Paris__48.85790400439863_2.358842071208555_10000&immo_sell_type=old,new&real_estate_type=1,2&price=50000-max"
    @source = "LeBonCoin"
    @xml_first_page = "body"
  end

  def extract_first_page
    xml = fetch_main_page(@url, @xml_first_page, "Captcha")
    if !xml[0].to_s.strip.empty?
      json = extract_json(xml)
      hashed_properties = []
      if !json.nil?
        json["data"]["ads"].each do |item|
          begin
            hashed_property = extract_each_flat(item)
            hashed_properties.push(hashed_property) if is_property_clean(hashed_property)
          rescue StandardError => e
            puts "\nError for #{@source}, skip this one."
            puts "It could be a bad link or a bad xml extraction.\n\n"
            next
          end
        end
        enrich_then_insert(hashed_properties)
      else
        puts "Error Parsing JSON.\n\n"
      end
    else
      puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
    end
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
