class ScraperLeBonCoin < Scraper

    attr_accessor :url, :properties, :source, :xml_first_page
  
    def initialize
      @url = 'https://www.leboncoin.fr/recherche/?category=9&locations=Paris__48.85790400439863_2.358842071208555_10000&immo_sell_type=old,new&real_estate_type=1,2&price=50000-max'
      @source = 'LeBonCoin'
      @xml_first_page = 'body'
    end
  
    def extract_first_page
      xml = fetch_first_page(@url, @xml_first_page, 'Captcha')
      if !xml[0].to_s.strip.empty?
        json = extract_json(xml)
        hashed_properties = []
        json['data']['ads'].each do |item|
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
        first_part = html.text.split("window.__REDIAL_PROPS__ = [null,null,null,null,null,")[1]
        second_part = first_part.split('</script>')[0].gsub('"status":"ready"}]', '"status":"ready"}')
        json.push(JSON.parse(second_part.tr("\r\n", '')))
      end
      return json[0]
    end
  
    def extract_each_flat(item)
      hashed_property = {}
  
      item['attributes'].each do |element|
        case element['key']
        when 'square'
          hashed_property[:surface] = element['value'].to_i 
        when 'rooms'
          hashed_property[:rooms_number] = element['value_label'].to_i 
        when 'real_estate_type'
          hashed_property[:flat_type] = element['value_label']
        end
      end
  
      !item['url'].nil? ? hashed_property[:link] = item['url'].gsub(' u002F', '/').gsub("\s", '') : nil
      !item['body'].nil? ? hashed_property[:description] = item['body'].tr("\n", '') : nil
      !item['location']['zipcode'].nil? ? hashed_property[:area] = item['location']['zipcode'] : nil
      !item['price'].nil? ? hashed_property[:price] = item['price'][0].to_i : nil
  
      hashed_property[:images] = []
      if !item['images']['urls_large'].nil? 
        hashed_property[:images] = item['images']['urls_large'] 
      elsif !item['images']['urls'].nil? 
        hashed_property[:images] = item['images']['urls'] 
      end
  
      hashed_property[:source] = @source
  
      case item['owner']['type']; when 'pro'; hashed_property[:provider] = 'Agence'; when 'private'; hashed_property[:provider] = 'Particulier'; else; hashed_property[:provider] = 'N/C' end
      return hashed_property
    end
  end 
