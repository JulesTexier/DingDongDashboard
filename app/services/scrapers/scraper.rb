# frozen_string_literal: true

require 'dotenv/load'

class Scraper
  def enrich_then_insert(prop)
    if !already_exists_with_desc?(prop) && !is_it_unwanted_prop?(prop) && !is_prop_fake?(prop)
      enriched_infos = perform_enrichment_regex(prop)
      prop.merge!(enriched_infos)
      prop[:area] = Area.where(name: prop[:area]).first
      prop = insert_property(prop)
      prop_historisation(prop, __method__, prop.id)
    else
      # for test purpose, if we don't want ton insert this shitty property,
      ## then we remove it from the final array of our dedicated scraper
      @properties.reject! { |h| h[:link] == prop[:link] }
    end
  end

  ########################
  ## HTML FETCH METHODS ##
  ########################

  def fetch_main_page(args)
    if !args.multi_page
      case args.scraper_type
      when 'Static'
        html = fetch_static_page(args.url)
      when 'Captcha'
        html = fetch_captcha_page(args.url)
      when 'Proxy'
        html = fetch_static_page_proxy_auth(args.url)
      when 'HTTPRequest'
        case args.http_type
        when 'get_json'
          json = fetch_json_get(args.url)
        when 'post_json'
          json = fetch_json_post(args.url, args.http_request)
        when 'post'
          html = fetch_http_page(args.url, args.http_request)
        end
      else
        puts 'Error'
      end
      json.nil? ? access_xml_raw(html, args.main_page_cls) : json
    else
      fetch_many_pages(args.url, args.page_nbr, args.main_page_cls)
    end
  end

  def fetch_static_page(url)
    attempt_count = 0
    max_attempts = 3
    begin
      attempt_count += 1
      res = URI.parse(url).open
      raise StaticError unless res.status[0] == '200'
    rescue
      sleep 1
      attempt_count < max_attempts ? retry : "Error in Fetch Static Page for url : #{url}."
    else
      page = Nokogiri::HTML.parse(res)
      return page
    end
  end

  def fetch_captcha_page(url)
    uri = URI('https://app.scrapingbee.com/api/v1/')
    params = { api_key: ENV['BEE_API'], url: url, premium_proxy: true, country_code: 'us' }
    uri.query = URI.encode_www_form(params)
    attempt_count = 0
    max_attempts = 3
    begin
      attempt_count += 1
      puts "\nAttempt ##{attempt_count} for Scrapping Bee - Captcha" unless Rails.env.test?
      res = Net::HTTP.get_response(uri)
      raise ScrappingBeeError unless res.code == "200"
    rescue
      puts "Trying again for Captcha - #{res.code}\n\n" unless Rails.env.test?
      sleep 1
      retry if attempt_count < max_attempts
    else
      puts "Worked on attempt n#{attempt_count} for Captcha\n\n" unless Rails.env.test?
      Nokogiri::HTML.parse(res.body)
    end
  end

  def fetch_http_page(url, http_request = [{}, {}])
    attempt_count = 0
    max_attempts = 3
    header = http_request[0].is_a?(String) ? JSON.parse(http_request[0]) : http_request[0]
    request = Typhoeus::Request.new(
      url,
      method: :post,
      headers: header,
      body: http_request[1]
    )
    begin
      attempt_count += 1
      request.run
      raise HttpPageError unless request.response.response_code == 200
    rescue
      sleep 1
      attempt_count < max_attempts ? retry : "Error in HTTP Post Request Page for url : #{url}."
    else
      Nokogiri::HTML.parse(request.response.response_body)
    end
  end

  def fetch_json_post(url, http_request)
    header = http_request[0].is_a?(String) ? JSON.parse(http_request[0]) : http_request[0]
    request = Typhoeus::Request.new(
      url,
      method: :post,
      headers: header,
      body: http_request[1]
    )
    response = request.run
    JSON.parse(response.body)
  end

  def fetch_json_get(url)
    request = Typhoeus::Request.new(
      url,
      method: :get
    )
    response = request.run
    JSON.parse(response.body)
  end

  def fetch_many_pages(url, page_nbr, xml_first_page)
    i = 1
    xml = []
    page_nbr.times do
      xml.push(access_xml_raw(fetch_static_page(page_nbr_to_url(url, i)), xml_first_page))
      i += 1
    end
    xml.flatten
  end

  #####################
  ## PROXY SERVICES  ##
  #####################

  def get_proxy_params
    url = "http://falcon.proxyrotator.com:51337/?apiKey=#{ENV['ROTATING_PROXY_API']}&connectionType=Datacenter"
    uri = URI(url)
    JSON.parse(Net::HTTP.get(uri))
  end

  def fetch_static_page_proxy_auth(url)
    proxy_params = get_proxy_params
    user_agent = proxy_params["randomUserAgent"]
    proxy_uri = URI.parse("http://199.189.86.111:#{ENV['PROXY_PORT']}")
    attempt_count = 0
    max_attempts = 3
    begin
      attempt_count += 1
      puts "\nAttempt ##{attempt_count} for Proxy - #{source}" unless Rails.env.test?
      res = open(url, :proxy_http_basic_authentication => [proxy_uri, ENV['USERNAME_ROT_PROXY'], ENV['PASSWORD_ROT_PROXY']], 'User-Agent' => user_agent)
      raise ProxyError unless res.status[0] == '200'
    rescue
      puts "Trying again for #{source} - Proxy\n\n" unless Rails.env.test?
      sleep 1
      retry if attempt_count < max_attempts
    else
      puts "Worked on attempt number #{attempt_count} for #{source} - Proxy \n\n" unless Rails.env.test?
      page = Nokogiri::HTML.parse(res)
      return page
    end
  end

  ###########################
  ## GENERIC METHOD  ##
  ###########################

  def page_nbr_to_url(url, page_nbr)
    url.gsub('[[PAGE_NUMBER]]', page_nbr.to_s)
  end

  def error_outputs(err, source)
    unless Rails.env.test?
      puts "\nError for #{@source}, skip this one."
      puts "It could be a bad link or a bad xml extraction.\n\n"
      puts err
    end
  end

  ###########################
  ## XML ACCESSORS METHODS ##
  ###########################

  def access_xml_text(page, css_selector)
    data = []
    page.css(css_selector).each do |item|
      data.push(item.text)
    end
    data.empty? ? '' : data.join(' ')
  end

  def access_xml_array_to_text(page, css_selector)
    data = []
    page.css(css_selector).each do |item|
      data.push(item.text)
    end
    data.join(' ')
  end

  def access_xml_link(page, css_selector, type)
    data = []
    page.css(css_selector).each do |item|
      data.push(item["#{type}"])
    end
    data
  end

  def access_xml_link_matchdata(page, css_selector, type, regexp)
    data = []
    page.css(css_selector).each do |item|
      data.push(item["#{type}"]) unless item["#{type}"].match(/#{regexp}/i).is_a?(MatchData)
    end
    data
  end

  def access_xml_link_matchdata_src(page, css_selector, type, regexp, src)
    data = []
    page.css(css_selector).each do |item|
      data.push(src + item["#{type}"]) unless item["#{type}"].match(/#{regexp}/i).is_a?(MatchData)
    end
    data
  end

  def access_xml_raw(page, css_selector)
    data = []
    unless page.nil?
      page.css(css_selector).each do |item|
        data.push(item)
      end
    end
    data
  end

  ####################
  ## REGEX METHODS ##
  ###################

  def regex_gen(str, regex)
    str.match(/#{regex}/i).to_s unless str.nil?
  end

  def perform_floor_regex(str)
    floor = str.remove_acc_scrp.convert_numerals_scrp.floors_str_scrp
    floor.to_int_scrp unless floor.nil?
  end

  def perform_elevator_regex(str)
    elevator = str.remove_acc_scrp.elevator_str_scrp
  end

  def perform_district_regex(str, zone = "Paris")
    district_datas = YAML.load_file("./db/data/areas.yml")
    district = []
    cleaned_str = str.perform_num_converter_scrp
    district_datas.each do |district_data|
      if district_data["zone"] == zone
        district_data["datas"].each do |city_data|
          if cleaned_str.match(/#{city_data["name"].remove_acc_scrp}/i).is_a?(MatchData)
            district.push(city_data["name"])
            break
          end
        end
        district_data["datas"].each do |city_data|
          city_data["terms"].each do |term|
            if cleaned_str.match(/\b#{term.remove_acc_scrp}\b/i).is_a?(MatchData)
              district.push(city_data["name"])
              break
            end
          end
        end
      end
    end
    district.uniq.empty? ? "N/C" : district[0]
  end

  ## We loop through a JSON File ISO to the DB to gain performance instead of looping in the entire db
  ## We then look in DB the ID of the subway object and assign the id (which is an array, that's odd)
  ## And the we send it in an array for insertion.
  def perform_subway_regex(str, zone = "Paris")
    subway_infos = []
    if zone == "Paris"
      subways = YAML.load_file("./db/data/subways.yml")
      subways["stations"].each do |subway|
        subway_infos.push(subway) if str.remove_acc_scrp.match(/#{subway["name"].remove_acc_scrp}/i).is_a?(MatchData)
      end
    end
    subway_infos.uniq
  end

  def perform_enrichment_regex(prop)
    enriched_infos = {}
    zone = prop[:area].include?("Paris") ? "Paris" : "Suburb"
    enriched_infos[:subway_infos] = perform_subway_regex(prop[:description], zone) unless prop.key?(:subway_infos) || prop.key?(:subway_ids)
    enriched_infos[:floor] = perform_floor_regex(prop[:description]) unless prop.key?(:floor)
    enriched_infos[:has_elevator] = perform_elevator_regex(prop[:description]) unless prop.key?(:has_elevator)
    enriched_infos[:has_garden] = prop[:description].garden_str_scrp unless prop.key?(:has_garden)
    enriched_infos[:has_terrace] = prop[:description].terrace_str_scrp unless prop.key?(:has_terrace)
    enriched_infos[:has_balcony] = prop[:description].balcony_str_scrp unless prop.key?(:has_balcony)
    enriched_infos[:is_last_floor] = prop[:description].last_floor_str_scrp unless prop.key?(:is_last_floor)
    enriched_infos
  end

  def get_type_flat(str)
    flat_type = 'N/C'
    flat_type = 'Appartement' if str.downcase.include? 'appartement'
    flat_type = 'Maison' if str.downcase.include? 'maison'
    flat_type = 'Studio' if str.downcase.include? 'studio'
    flat_type = 'Loft' if str.downcase.include? 'loft'
    flat_type = 'Cave' if str.downcase.include? 'cave'
    flat_type = 'Parking' if str.downcase.include? 'parking'
    flat_type = 'Commerce' if str.downcase.include? 'commerce'
    flat_type = 'Bureaux' if str.downcase.include? 'bureaux'
    flat_type = 'Hotel particulier' if str.downcase.include? 'hotel particulier'
    flat_type
  end

  #############################
  ## PUBLIC DATABASE METHODS ##
  #############################

  ## This methods make multiple checks to see if we can go to a
  ## property seen on the main page, for performance reasons

  def go_to_prop?(prop, time)
    if !is_prop_fake?(prop) ## we check if the property is fake if we have enough informations (surface + price)
      if is_link_in_db?(prop) ## we check if the prop is in DB by its link
        false ## we dont go to the property show because we already have it
      else ## it doesnt exist in db so we check by 3 - 4 keys if its already in DB from another source
        filtered_prop = prop.select { |k, v| !v.nil? && [:area, :rooms_number, :surface, :price].include?(k) } ## we only keep existants arguments
        if filtered_prop.length > 2 ## we verify that theres at least 3 arguements
          does_prop_exists?(prop, time) ? false : true ## if it doesnt exist, we go to the show
        else ## not enought args, so fuck off we dont go to the show
          prop_historisation(prop, __method__)
          false
        end
      end
    else
      false ## prop is fake so goodbye we dont go the the show.
    end
  end

  def does_prop_exists?(prop, time)
    response = false
    filtered_prop = prop.select { |k, v| !v.nil? && [:area, :rooms_number, :surface, :price].include?(k) }
    if filtered_prop[:area].nil?
      parent_prop_id = Property.where(
        filtered_prop.except(:area)
      ).where('created_at >= ?', time.days.ago).pluck(:id)
    else
      filtered_prop[:area_id] = Area.find_by(name: filtered_prop[:area]).id
      parent_prop_id = Property.where(
        filtered_prop.except(:area),
      ).where('created_at >= ?', time.days.ago).pluck(:id)
    end
    response = parent_prop_id.any?
    prop_historisation(prop, __method__, parent_prop_id[0]) if response
    response
  end

  def is_link_in_db?(prop)
    parent_prop_id = Property.where(link: prop[:link].strip).pluck(:id)
    response = parent_prop_id.any?
    prop_historisation(prop, __method__, parent_prop_id[0]) if response
    response
  end

  def is_prop_fake?(prop)
    if prop[:surface].nil? || prop[:price].nil? || prop[:area].nil?
      ## delibarately not enough informations, we should further check
      ## if we put thoses attributes to nil, it means that we can't have informations on the main page
      ## but that we probably can retrieve it in property show
      response = false
    elsif prop[:price].to_i != 0 && prop[:surface].to_i != 0 && prop[:area] != "N/C"
      price_threshold = prop[:area].include?("Paris") ? 7000 : 1000
      sqm = prop[:price].to_i / prop[:surface].to_i
      response = sqm < price_threshold
    else
      response = true ## not enough informations, we should further check
    end
    prop_historisation(prop, __method__) if response
    response
  end

  ## Is a final check, and check if it already exists with description
  ## check also if rooms_number or price is nil, if it is, then no insertion
  ## check also if the area is not found, if so, no insertion
  def already_exists_with_desc?(hashed_property)
    response = false

    if hashed_property[:area] == "N/C" || hashed_property[:rooms_number].nil? || hashed_property[:price].nil? || hashed_property[:surface].nil?
      response = true
    else
      properties = Property.where(
        surface: hashed_property[:surface],
        price: hashed_property[:price],
        area: Area.where(name: hashed_property[:area]).first,
      ).pluck(:id, :description)

      properties.each do |property|
        response = desc_comparator(property[1], hashed_property[:description])
        prop_historisation(hashed_property, __method__, property[0]) if response
        break if response
      end
    end
    response
  end

  ## We check if its not a Viagier / Under Offer / Parking Lot / A ferme Vosgienne
  def is_it_unwanted_prop?(prop)
    response = prop[:description].remove_acc_scrp.match(/(appartement(s?)|bien(s?)|residence(s?))(.?)(deja vendu|sous compromis|service(s?))|(ehpad|viager)|(sous offre actuellement)|(local commercial)/i).is_a?(MatchData)
    prop_historisation(prop, __method__) if response
    response
  end

  def it_night?
    response = false
    a = Time.parse('22:00:00 +0200')
    b = Time.parse('09:00:00 +0200')
    c = Time.now.getlocal('+02:00')
    if c > a || c < b
      response = true
    end
    response
  end

  #############################
  ## ALGORYTHMIC DESCRIPTION ##
  #############################

  def desc_comparator(desc, desc_to_compare)
    response = false
    str1 = desc.remove_acc_scrp.tr(".,!?:;'", '').tr('²', '2').tr("\s\t\r", '')
    str2 = desc_to_compare.remove_acc_scrp.tr(".,!?:;'", '').tr('²', '2').tr("\s\t\r", '')
    min = [str1.length, str2.length].min
    if min > 20
      if str1.length == min
        short_string = str1
        long_string = str2
      else
        short_string = str2
        long_string = str1
      end
      if min > 44
        min = 44
        x = short_string.length - min
      else
        x = short_string.length - min + 1
      end
      i = 0
      sample_strings = []
      x.times do
        j = i + min
        sample_strings.push(short_string[i..j])
        i += 1
      end
      sample_strings.each do |sample_string|
        response = true if long_string.include?(sample_string)
      end
    end
    response
  end

  #########################################
  ## CHECKER TO SEE IF EVERYTHING IS FINE##
  #########################################

  def scraped_property_count(time_frame)
    Property.where("created_at >= ?", Time.zone.now - time_frame.to_i.hours).count
  end

  def scraped_property_checker
    time_frame = ENV['TIME_FRAME_ALERT'].nil? ? 6 : ENV['TIME_FRAME_ALERT']
    prop_nbr = scraped_property_count(time_frame)
    if prop_nbr.zero?
      message = "ALERTE. Ceci n'est pas un exercice, nous n'avons pas scrapé d'annonces en #{time_frame} heure(s)"
      sms_mode = SmsMode.new
      sms_mode.send_sms_to_team(message)
      puts "\n\n" + message + "\n\n"
    else
      property_word = prop_nbr > 1 ? 'properties' : 'property'
      puts "\n\nEverything seems to be fine."
      puts "We've scraped #{prop_nbr} #{property_word} in a #{time_frame} hour window.\n\n"
    end
  end

  #####################################
  ## PARAMS METHODS FOR CITY OPENING ##
  #####################################

  def fetch_init_params(source, is_mail_alert = false)
    parameters = ScraperParameter.where(source: source)
    data = []
    parameters.each do |param|
      if param.is_active == true
        if is_mail_alert
          data.push(param) if param.group_type == 'Email'
        else
          data.push(param) if param.group_type != 'Email'
        end
      end
    end
    data
  end

  ########################
  ## PROP HISTORIZATION ##
  ########################

  def prop_historisation(prop, method_name, parent_prop_id = nil)
    prop[:source] = self.source unless Rails.env.test?
    insert_property_link(prop, method_name, parent_prop_id) unless PropertyLink.where(link: prop[:link]).exists?
  end

  private

  ##############################
  ## PRIVATE DATABASE METHODS ##
  ##############################

  def insert_property_link(hashed_property, method_name, parent_prop_id)
    prop_hst = PropertyLink.new(hashed_property.slice(:link, :description, :source, :images))
    prop_hst.method_name = method_name
    prop_hst.property_id = parent_prop_id.nil? ? nil : parent_prop_id
    if prop_hst.save
      puts "\n\nInsertion of property history - #{self.source} -> #{method_name}" unless Rails.env.test?
    end
  end

  def insert_property(prop_hash)
    prop_hash[:has_been_processed] = true if it_night?
    prop = Property.create(prop_hash)
    if prop.save
      unless Rails.env.test?
        puts "\nInsertion of a property from #{prop_hash[:source]}: "
        puts prop.get_title
      end
      prop
    end
  end
end
