require 'nokogiri'
require 'open-uri'

class Scraper

  def enrich_then_insert(hashed_properties)
    hashed_properties.each do |hashed_property|
      property = insert_property(hashed_property)
      insert_property_images(hashed_property[:images], property) unless property.nil?
    end
  end

  ########################
  ## HTML FETCH METHODS ##
  ########################

  def fetch_first_page(url, xml_first_page, type = 'Static', waiting_class = nil)
    case type
    when 'Static'
      html = fetch_static_page(url)
    when 'Dynamic'
      html = fetch_dynamic_page(url, waiting_class)
    when 'Captcha'
      html = fetch_captcha_page(url)
    else 
      puts "Error"
    end
    card = access_xml_raw(html, xml_first_page)
  end

  def fetch_static_page(url)
    page = Nokogiri::HTML(open(url))
    return page
  end

  def fetch_dynamic_page(url, waiting_class)
    browser = Watir::Browser.new :chrome, headless: true
    browser.ignore_exceptions = true
    browser.goto url
    browser.link(class: waiting_class).wait_until(&:present?)
    page = Nokogiri::HTML.parse(browser.html)
  end

  def fetch_captcha_page(url)
    uri = URI('https://app.scrapingbee.com/api/v1/')
    params = { :api_key => 'JS5YI3NJN7GG22GKYLYZGD94LE0HJ6I9G6THYL5TZ2MW024W94DCGSMQQ00RGT4ERGMG2SNJPE8KW8ZJ', :url => url, :premium_proxy => true, :country_code => 'us'}
    uri.query = URI.encode_www_form(params)
    attempt_count = 0
    max_attempts  = 3
    begin
      attempt_count += 1
      puts "\nAttempt ##{attempt_count} for Scrapping Bee - #{source}"
      res = Net::HTTP.get_response(uri)
      raise ScrappingBeeError unless res.code == '200'
    rescue 
      puts "Trying again for #{source} - #{res.code}\n\n"
      sleep 1
      retry if attempt_count < max_attempts
    else
      puts "Worked on attempt n°#{attempt_count} for #{source}\n\n"
      page = Nokogiri::HTML.parse(res.body)
      return page
    end
  end

  ###########################
  ## XML ACCESSORS METHODS ##
  ###########################

  def access_xml_text(page, css_selector)
    page.css(css_selector).each do |item|
      return item.text
    end
  end

  def access_xml_array_to_text(page, css_selector)
    data = []
    page.css(css_selector).each do |item|
      data.push(item.text)
    end
    return data.join(' ')
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

  #######################
  ## PUBLIC DATABASE METHODS ##
  #######################

  def is_already_exists(hashed_property)
    response = false
    properties = Property.where(
      price: hashed_property[:price],
      surface: hashed_property[:surface],
      rooms_number: hashed_property[:rooms_number],
      area: hashed_property[:area]
    )
    response = true if properties.length > 0
  end

  def is_dirty_property(hashed_property)
    response = false 
    if !hashed_property[:price].nil? && !hashed_property[:surface].nil? && hashed_property[:surface] != 0
      sqm = hashed_property[:price].to_i / hashed_property[:surface].to_i
      if sqm < 5000
        response = true
      end
    end
    response = true if hashed_property[:link].to_s.strip.empty?
    return response
  end

  def is_property_clean(hashed_property)
    is_already_exists(hashed_property) || is_dirty_property(hashed_property) ? false : true
  end

  def is_it_late
    response = false
    a = Time.parse('22:00:00 +0100')
    b = Time.parse('09:00:00 +0100')
    c = Time.now.getlocal("+01:00")
    if c > a || c < b
      response = true
    end
    return response
  end

  private

  ##############################
  ## PRIVATE DATABASE METHODS ##
  ##############################

  def insert_property(prop_hash)
    prop_hash[:has_been_processed] = true if is_it_late
    if prop = Property.create(prop_hash.except(:images))
      puts "\nInsertion of a property from #{prop_hash[:source]}: "
      puts prop.get_title
      return prop
    end
  end

  def insert_property_images(image_array, prop)
    image_array.each do |img|
      PropertyImage.create(property_id: prop.id, url: img)
    end
    prop.images.length > 0 ? nil : PropertyImage.create(property: prop)
  end

end 