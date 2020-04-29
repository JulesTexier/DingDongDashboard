require "dotenv/load"

class Scraper
  def enrich_then_insert_v2(hashed_property)
    if !is_already_exists_by_desc?(hashed_property) && !is_it_unwanted_prop?(hashed_property[:description]) && !is_prop_fake?(hashed_property)
      hashed_property[:area] = Area.where(name: hashed_property[:area]).first
      property = insert_property(hashed_property)
      insert_property_subways(hashed_property[:subway_ids], property) unless property.nil? || hashed_property[:subway_ids].nil? || hashed_property[:subway_ids].empty?
    else
      # for test purpose, if we don't want ton insert this shitty property,
      ## then we remove it from the final array of our dedicated scraper
      @properties.reject! { |h| h[:link] == hashed_property[:link] }
    end
  end

  ########################
  ## HTML FETCH METHODS ##
  ########################

  def fetch_main_page(args)
    if !args.multi_page
      case args.type
      when "Static"
        html = fetch_static_page(args.url)
      when "Dynamic"
        html = fetch_dynamic_page(args.url, args.waiting_cls, args.wait, *args.click_args)
      when "Captcha"
        html = fetch_captcha_page(args.url)
      when "HTTPRequest"
        case args.http_type
        when "get_json"
          json = fetch_json_get(args.url)
        when "post_json"
          json = fetch_json_post(args.url, args.http_request)
        when "post"
          html = fetch_http_page(args.url, args.http_request)
        end
      else
        puts "Error"
      end
      json.nil? ? access_xml_raw(html, args.main_page_cls) : json
    else
      card = fetch_many_pages(args.url, args.page_nbr, args.main_page_cls)
    end
  end

  def fetch_main_page_multi_city(args)
    if !args["multi_page"]
      case args["type"]
      when "Static"
        html = fetch_static_page(args["url"])
      when "Captcha"
        html = fetch_captcha_page(args["url"])
      when "HTTPRequest"
        case args["http_type"]
        when "get_json"
          json = fetch_json_get(args["url"])
        when "post_json"
          json = fetch_json_post(args["url"], args["http_request"])
        when "post"
          html = fetch_http_page(args["url"], args["http_request"])
        end
      else
        puts "Error"
      end
      json.nil? ? access_xml_raw(html, args["main_page_cls"]) : json
    else
      card = fetch_many_pages(args["url"], args["page_nbr"], args["main_page_cls"])
    end
  end

  def fetch_static_page(url)
    page = Nokogiri::HTML(open(url))
    return page
  end

  def fetch_dynamic_page(url, waiting_class, wait, *click_args)
    opts = {
      headless: true,
    }
    browser = Watir::Browser.new :chrome, opts
    browser.goto url
    sleep wait
    click_those_btns(browser, click_args) unless click_args.nil?
    browser.div(class: waiting_class).wait_until(&:present?)
    page = Nokogiri::HTML.parse(browser.html)
    browser.close
    return page
  end

  def fetch_captcha_page(url)
    uri = URI("https://app.scrapingbee.com/api/v1/")
    params = { :api_key => ENV["BEE_API"], :url => url, :premium_proxy => true, :country_code => "us" }
    uri.query = URI.encode_www_form(params)
    attempt_count = 0
    max_attempts = 3
    begin
      attempt_count += 1
      puts "\nAttempt ##{attempt_count} for Scrapping Bee - #{source}" unless Rails.env.test?
      res = Net::HTTP.get_response(uri)
      raise ScrappingBeeError unless res.code == "200"
    rescue
      puts "Trying again for #{source} - #{res.code}\n\n" unless Rails.env.test?
      sleep 1
      retry if attempt_count < max_attempts
    else
      puts "Worked on attempt n°#{attempt_count} for #{source}\n\n" unless Rails.env.test?
      page = Nokogiri::HTML.parse(res.body)
      return page
    end
  end

  def fetch_http_page(url, http_request)
    request = Typhoeus::Request.new(
      url,
      method: :post,
      headers: http_request[0],
      body: http_request[1],
    )
    request.run
    return Nokogiri::HTML(request.response.body)
  end

  def fetch_json_post(url, http_request)
    request = Typhoeus::Request.new(
      url,
      method: :post,
      headers: http_request[0],
      body: http_request[1],
    )
    response = request.run
    return JSON.parse(response.body)
  end

  def fetch_json_get(url)
    request = Typhoeus::Request.new(
      url,
      method: :get,
    )
    response = request.run
    return JSON.parse(response.body)
  end

  def fetch_many_pages(url, page_nbr, xml_first_page)
    i = 1
    xml = []
    page_nbr.times do
      xml.push(access_xml_raw(fetch_static_page(page_nbr_to_url(url, i)), xml_first_page))
      i += 1
    end
    return xml.flatten
  end

  #####################
  ## PROXY SERVICES  ##
  #####################

  def fetch_proxy_params
    proxy_url = "http://falcon.proxyrotator.com:51337/?apiKey=#{ENV["ROTATING_PROXY_API"]}&country=US"
    uri = URI(proxy_url)
    return JSON.parse(Net::HTTP.get(uri))
  end

  def get_user_agent(proxy_params)
    user_agent_url = "https://httpbin.org/user-agent"
    user_agent = proxy_params["randomUserAgent"]
    puts user_agent
    open(user_agent_url, "User-Agent" => user_agent, "read_timeout" => "10").read
  end

  def get_whole_header(proxy_params)
    header_url = "https://httpbin.org/headers"
    ip_url = "https://httpbin.org/ip"
    user_agent_url = "https://httpbin.org/user-agent"
    user_agent = proxy_params["randomUserAgent"]
    proxy_ip = "http://" + proxy_params["proxy"]
    puts "This is the User_Agent => " + user_agent
    puts "This is our Proxy => " + proxy_ip
    user_agent_page = open(user_agent_url, "User-Agent" => user_agent).read
    ip_page = open(ip_url, proxy: URI.parse(proxy_ip)).read
    header_page = open(header_url, proxy: URI.parse(proxy_ip), "User-Agent" => user_agent).read
  end

  def change_ip(proxy_params, url)
    uri = URI("https://httpbin.org/ip")
    http = Net::HTTP.new(uri.host, uri.port)
    http.local_host = proxy_params["ip"]
    http.use_ssl = true
    request = Net::HTTP::Get.new("/")
    request.content_type = "application/json"
    request.initialize_http_header("Content-Type" => "application/json")
    response = http.request(request)
    puts response.body
  end

  def get_ip(proxy_params)
    ip_url = "https://httpbin.org/ip"
    proxy_ip = "http://" + proxy_params["proxy"]
    puts proxy_ip
    puts open(ip_url, "proxy" => URI.parse(proxy_ip)).read
  end

  def get_website(url, proxy_params)
    user_agent = proxy_params["randomUserAgent"]
    proxy_ip = proxy_params["proxy"]
    open(url, proxy: URI.parse(proxy_ip), "User-Agent" => user_agent).read
  end

  ###########################
  ## GENERIC METHOD  ##
  ###########################

  def page_nbr_to_url(url, page_nbr)
    url.gsub("[[PAGE_NUMBER]]", page_nbr.to_s)
  end

  def error_outputs(e, source)
    unless Rails.env.test?
      puts "\nError for #{@source}, skip this one."
      puts "It could be a bad link or a bad xml extraction.\n\n"
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
    data.empty? ? "" : data.join(" ")
  end

  def access_xml_array_to_text(page, css_selector)
    data = []
    page.css(css_selector).each do |item|
      data.push(item.text)
    end
    return data.join(" ")
  end

  def access_xml_link(page, css_selector, type)
    data = []
    page.css(css_selector).each do |item|
      data.push(item["#{type}"])
    end
    return data
  end

  def access_xml_link_matchdata(page, css_selector, type, regexp)
    data = []
    page.css(css_selector).each do |item|
      data.push(item["#{type}"]) unless item["#{type}"].match(/#{regexp}/i).is_a?(MatchData)
    end
    return data
  end

  def access_xml_link_matchdata_src(page, css_selector, type, regexp, src)
    data = []
    page.css(css_selector).each do |item|
      data.push(src + item["#{type}"]) unless item["#{type}"].match(/#{regexp}/i).is_a?(MatchData)
    end
    return data
  end

  def access_xml_raw(page, css_selector)
    data = []
    unless page.nil?
      page.css(css_selector).each do |item|
        data.push(item)
      end
    end
    return data
  end

  ####################
  ## REGEX METHODS ##
  ###################

  def regex_gen(str, regex)
    str.match(/#{regex}/i).to_s unless str.nil?
  end

  def perform_floor_regex(str)
    floor = str.remove_acc_scrp.convert_numerals_scrp.floors_str_scrp
    return floor.to_int_scrp unless floor.nil?
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
    if zone == "Paris"
      subways = JSON.parse(File.read("./db/data/subways.json"))
      subways_ids = []
      subways["stations"].each do |subway|
        if str.remove_acc_scrp.match(/#{subway["metro"].remove_acc_scrp}/i).is_a?(MatchData)
          s = Subway.where(name: subway["metro"]).limit(1)
          subways_ids.push(s.ids[0])
        end
      end
      return subways_ids.uniq
    end
  end

  def get_type_flat(str)
    flat_type = "N/C"
    flat_type = "Appartement" if str.downcase.include? "appartement"
    flat_type = "Maison" if str.downcase.include? "maison"
    flat_type = "Studio" if str.downcase.include? "studio"
    flat_type = "Loft" if str.downcase.include? "loft"
    flat_type = "Cave" if str.downcase.include? "cave"
    flat_type = "Parking" if str.downcase.include? "parking"
    flat_type = "Commerce" if str.downcase.include? "commerce"
    flat_type = "Bureaux" if str.downcase.include? "bureaux"
    flat_type = "Hotel particulier" if str.downcase.include? "hotel particulier"
    return flat_type
  end

  #############################
  ## PUBLIC DATABASE METHODS ##
  #############################

  ## This methods make multiple checks to see if we can go to a
  ## property seen on the main page, for performance reasons

  def go_to_prop?(prop, time)
    if !is_prop_fake?(prop) ## we check if the property is fake if we have enough informations (surface + price)
      if is_link_in_db?(prop) ## we check if the prop is in DB by its link
        false ##we dont go to the property show because we already have it
      else ## it doesnt exist in db so we check by 3 - 4 keys if its already in DB from another source
        filtered_prop = prop.select { |k, v| !v.nil? && [:area, :rooms_number, :surface, :price].include?(k) } ## we only keep existants arguments
        if filtered_prop.length > 2 ## we verify that theres at least 3 arguements
          does_prop_exists?(filtered_prop, time) ? false : true ## if it doesnt exist, we go to the show
        else ## not enought args, so fuck off we dont go to the show
          false
        end
      end
    else
      false ## prop is fake so goodbye we dont go the the show.
    end
  end

  def does_prop_exists?(prop, time)
    if prop[:area].nil?
      props = Property.where(
        prop.except(:area)
      ).where("created_at >= ?", time.days.ago)
    else
      props = Property.where(
        prop.except(:area),
        area: Area.where(name: prop[:area]).first,
      ).where("created_at >= ?", time.days.ago)
    end
    props.count == 0 ? false : true
  end

  def is_link_in_db?(prop)
    props = Property.where(link: prop[:link].strip)
    props.count == 0 ? false : true
  end

  def is_prop_fake?(prop)
    if prop[:surface].nil? || prop[:price].nil? || prop[:area].nil?
      ## delibarately not enough informations, we should further check
      ## if we put thoses attributes to nil, it means that we can't have informations on the main page
      ## but that we probably can retrieve it in property show
      false
    elsif prop[:price].to_i != 0 && prop[:surface].to_i != 0 && prop[:area] != "N/C"
      price_threshold = prop[:area].include?("Paris") ? 5000 : 1000
      sqm = prop[:price].to_i / prop[:surface].to_i
      sqm < price_threshold ? true : false
    else
      true ## not enough informations, we should further check
    end
  end

  def is_already_exists_by_desc?(hashed_property)
    response = false

    properties = Property.where(
      surface: hashed_property[:surface],
      price: hashed_property[:price],
      area: Area.where(name: hashed_property[:area]).first,
      rooms_number: hashed_property[:rooms_number],
    )

    properties.each do |property|
      response = desc_comparator(property.description, hashed_property[:description])
      break if response
    end
    return response
  end

  ## We check if its not a Viagier / Under Offer / Parking Lot / A ferme Vosgienne
  def is_it_unwanted_prop?(str)
    str.remove_acc_scrp.match(/(appartement(s?)|bien(s?)|residence(s?))(.?)(deja vendu|sous compromis|service(s?))|(ehpad|viager)|(sous offre actuellement)/i).is_a?(MatchData)
  end

  def is_it_night?
    response = false
    a = Time.parse("22:00:00 +0200")
    b = Time.parse("09:00:00 +0200")
    c = Time.now.getlocal("+02:00")
    if c > a || c < b
      response = true
    end
    return response
  end

  #############################
  ## ALGORYTHMIC DESCRIPTION ##
  #############################

  def desc_comparator(desc, desc_to_compare)
    response = false
    str1 = desc.remove_acc_scrp.tr(".,!?:;'", "").tr("²", "2").tr("\s\t\r", "")
    str2 = desc_to_compare.remove_acc_scrp.tr(".,!?:;'", "").tr("²", "2").tr("\s\t\r", "")
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
      array = []
      x.times do
        j = i + min
        array.push(short_string[i..j])
        i += 1
      end
      array.each do |papouz|
        response = true if long_string.include?(papouz)
      end
    end
    return response
  end

  #########################################
  ## CHECKER TO SEE IF EVERYTHING IS FINE##
  #########################################

  def scraped_property_count(time_frame)
    Property.where("created_at >= ?", Time.zone.now - time_frame.to_i.hours).count
  end

  def scraped_property_checker
    time_frame = ENV["TIME_FRAME_ALERT"].nil? ? 6 : ENV["TIME_FRAME_ALERT"]
    prop_nbr = scraped_property_count(time_frame)
    if prop_nbr == 0
      message = "ALERTE. Ceci n'est pas un exercice, nous n'avons pas scrapé d'annonces en #{time_frame} heure(s)"
      sms_mode = SmsMode.new
      sms_mode.send_sms_to_team(message)
      puts "\n\n" + message + "\n\n"
    else
      property_word = prop_nbr > 1 ? "properties" : "property"
      puts "\n\nEverything seems to be fine."
      puts "We've scraped #{prop_nbr} #{property_word} in a #{time_frame} hour window.\n\n"
    end
  end

  #####################################
  ## PARAMS METHODS FOR CITY OPENING ##
  #####################################

  def fetch_init_params(source)
    yaml_file = YAML.load_file("./db/data/scraper_params.yml")
    data = []

    yaml_file.each do |scraper|
      if scraper["source"] == source
        data = scraper["params"]
      end
    end
    return data
  end

  private

  ##############################
  ## PRIVATE DATABASE METHODS ##
  ##############################

  def insert_property(prop_hash)
    prop_hash[:has_been_processed] = true if is_it_night?
    prop = Property.create(prop_hash)
    if prop.save
      unless Rails.env.test?
        puts "\nInsertion of a property from #{prop_hash[:source]}: "
        puts prop.get_title
      end
      return prop
    end
  end

  def insert_property_subways(subway_ids, prop)
    subway_ids.each do |subway_id|
      PropertySubway.create(property_id: prop.id, subway_id: subway_id) if PropertySubway.where(property_id: prop.id, subway_id: subway_id).empty?
    end
  end
end
