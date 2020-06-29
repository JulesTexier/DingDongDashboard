class Proxy::ScraperSeLoger < Scraper
  attr_accessor :properties, :source, :params

  def initialize
    @source = "SeLoger"
    @params = fetch_init_params(@source)
    @properties = []
  end

  def launch(limit = nil)
    i = 0
    self.params.each do |args|
      xml = access_xml_raw(fetch_static_page_proxy_auth(args.url), args.main_page_cls)
      extract_json(xml)["cards"]["list"].each do |item|
        begin
          if item["cardType"] == "classified" && item.keys[0] == "id"
            hashed_property = {}
            hashed_property[:price] = item["pricing"]["price"].to_int_scrp
            hashed_property[:images] = item["photos"].map { |img| img.gsub("/400/visuels", "/800/visuels") }
            hashed_property[:area] = perform_district_regex(item["zipCode"], args.zone)
            hashed_property[:link] = item["classifiedURL"]
            hashed_property[:is_new_construction] = item["classifiedURL"].include?("bellesdemeures") || item["classifiedURL"].include?("selogerneuf")
            item["tags"].each do |infos|
              surface_regex = '\d(.)*m²'
              rooms_regex = '\d(.)*p'
              bedrooms_regex = '\d(.)*ch'
              hashed_property[:surface] = infos.to_float_to_int_scrp if infos.match(surface_regex)
              hashed_property[:rooms_number] = infos.to_int_scrp if infos.match(rooms_regex)
              hashed_property[:bedrooms_number] = infos.to_int_scrp if infos.match(bedrooms_regex)
            end
            next if hashed_property[:surface].nil? || hashed_property[:rooms_number].nil?
            hashed_property[:flat_type] = get_type_flat(item["estateType"])
            hashed_property[:agency_name] = item["contact"]["contactName"]
            hashed_property[:contact_number] = item["contact"]["phoneNumber"].sl_phone_number_scrp
            hashed_property[:source] = @source
            hashed_property[:provider] = "Agence"
            hashed_property[:description] = item["description"]
            if go_to_prop?(hashed_property, 7) && hashed_property[:agency_name] != "Ding Dong"
              @properties.push(hashed_property)
              enrich_then_insert(hashed_property)
              i += 1
            end
            break if i == limit
          end
        rescue StandardError => e
          error_outputs(e, @source)
          next
        end
      end
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
end
