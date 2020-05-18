class Premium::ScraperSeLoger < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "SeLoger"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      html = fetch_static_page_proxy_auth(args.url)
      xml = access_xml_raw(html, args.main_page_cls)
      json = extract_json(xml)
      json["cards"]["list"].each do |item|
        if item["cardType"] == "classified"
          begin
            hashed_property = extract_each_flat(item)
            property_checker_hash = {}
            property_checker_hash[:rooms_number] = hashed_property[:rooms_number]
            property_checker_hash[:surface] = hashed_property[:surface]
            property_checker_hash[:price] = hashed_property[:price]
            property_checker_hash[:area] = hashed_property[:area]
            property_checker_hash[:link] = hashed_property[:link]
            if go_to_prop?(property_checker_hash, 7) && hashed_property[:agency_name] != "Ding Dong"
              puts JSON.pretty_generate(hashed_property)
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
      end
      # else
      #   puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
      # end
    end
    return @properties
  end

  private

  def extract_json(html_array)
    json = []
    html_array.each do |html|
      regex_brackets = '(window\[.*?\])'
      regex_no_brackets = "window.initialData"
      if html.text.match(/#{regex_brackets}/i).is_a? MatchData
        first_part = html.text.split('JSON.parse("')[1]
        second_part = first_part.split('");window["tags"]')[0]
        seloger_json = JSON.parse(second_part.decode_json_scrp)
        json.push(seloger_json)
      elsif html.text.match(/#{regex_no_brackets}/i).is_a? MatchData
        first_part = html.text.split('JSON.parse("')[1]
        second_part = first_part.split(";window.tags =")[0]
        seloger_json = JSON.parse(second_part.decode_json_scrp)
        json.push(seloger_json)
      end
    end
    return json[0]
  end

  def extract_each_flat(item)
    if item.keys[0] === "id"
      flat_data = {}
      flat_data[:price] = item["pricing"]["price"].to_int_scrp
      flat_data[:images] = []
      item["photos"].each do |img|
        flat_data[:images].push(img.gsub("/400/visuels", "/800/visuels"))
      end
      flat_data[:area] = perform_district_regex(item["zipCode"])
      flat_data[:description] = item["description"] + " ... - #{flat_data[:area_district]}"
      flat_data[:link] = item["classifiedURL"]
      item["tags"].each do |infos|
        surface_regex = '\d(.)*m²'
        rooms_regex = '\d(.)*p'
        bedrooms_regex = '\d(.)*ch'
        flat_data[:surface] = infos.to_float_to_int_scrp if infos.match(surface_regex)
        flat_data[:rooms_number] = infos.to_int_scrp if infos.match(rooms_regex)
        flat_data[:bedrooms_number] = infos.to_int_scrp if infos.match(bedrooms_regex)
      end
      flat_data[:flat_type] = item["estateType"]
      flat_data[:agency_name] = item["contact"]["contactName"]
      flat_data[:contact_number] = item["contact"]["phoneNumber"].sl_phone_number_scrp
      flat_data[:floor] = perform_floor_regex(flat_data[:description])
      flat_data[:has_elevator] = perform_elevator_regex(flat_data[:description])
      flat_data[:subway_ids] = perform_subway_regex(flat_data[:description])
      flat_data[:source] = @source
      flat_data[:provider] = "Agence"
      return flat_data
    end
  end
end
