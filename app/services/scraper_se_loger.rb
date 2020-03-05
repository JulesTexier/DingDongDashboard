class ScraperSeLoger < Scraper

    attr_accessor :url, :properties, :source, :xml_first_page
  
    def initialize
      @url = 'https://www.seloger.com/list.htm?projects=2,5&types=1,2&natures=1,2,4&places=[{cp:75}]&sort=d_dt_crea&enterprise=0&qsVersion=1.0'
      @source = 'SeLoger'
      @xml_first_page = 'script'
    end
  
    def extract_first_page
      xml = fetch_first_page(@url, @xml_first_page, 'Captcha')
      if !xml[0].to_s.strip.empty?
        json = extract_json(xml)
        hashed_properties = []
        json['cards']['list'].each do |item|
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
        puts "\nERROR : Couldn't fetch #{@source} datas.\n\n"
      end
    end
  
    private
  
    def extract_json(html_array)
      json = []
      html_array.each do |html|
        regex_brackets = '(window\[.*?\])'
        regex_no_brackets = 'window.initialData'
        if html.text.match(/#{regex_brackets}/i).is_a? MatchData
          first_part = html.text.split('JSON.parse("')[1]
          second_part = first_part.split('");window["tags"]')[0]
          seloger_json = JSON.parse(second_part.decode_json)
          json.push(seloger_json)
        elsif html.text.match(/#{regex_no_brackets}/i).is_a? MatchData
          first_part = html.text.split('JSON.parse("')[1]
          second_part = first_part.split(';window.tags =')[0]
          seloger_json = JSON.parse(second_part.decode_json)
          json.push(seloger_json)
        end
      end
      return json[0]
    end
  
    def extract_each_flat(item)
      if item.keys[0] === 'id'
        hashed_property = {}
        hashed_property[:price] = item['pricing']['price'].to_int
        hashed_property[:images] = []
        item['photos'].each do |img|
          hashed_property[:images].push(img.gsub('/400/visuels', '/800/visuels'))
        end
        hashed_property[:area] = item['zipCode']
        hashed_property[:description] = item['description'] + " ... - #{hashed_property[:area_district]}"
        hashed_property[:link] = item['classifiedURL']
        item['tags'].each do |infos|
          surface_regex = '\d(.)*m²'
          rooms_regex = '\d(.)*p'
          bedrooms_regex = '\d(.)*ch'
          hashed_property[:surface] = infos.to_int if infos.match(surface_regex)
          hashed_property[:rooms_number] = infos.to_int if infos.match(rooms_regex)
          hashed_property[:bedrooms_number] = infos.to_int if infos.match(bedrooms_regex)
        end
        hashed_property[:flat_type] = item['estateType']
        hashed_property[:agency_name] = item['contact']['contactName']
        hashed_property[:contact_number] = item['contact']['phoneNumber']
        hashed_property[:floor] = perform_floor_regex(hashed_property[:description])
        hashed_property[:has_elevator] = perform_elevator_regex(hashed_property[:description])
        hashed_property[:source] = @source
        hashed_property[:provider] = 'Agence'
        return hashed_property
      end
    end
  end 