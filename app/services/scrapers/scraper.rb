require "dotenv/load"

class Scraper
  def enrich_then_insert(hashed_properties)
    hashed_properties.each do |hashed_property|
      property = insert_property(hashed_property)
      insert_property_subways(hashed_property[:subway_ids], property) unless property.nil? || hashed_property[:subway_ids].nil? || hashed_property[:subway_ids].empty?
    end
  end

  def enrich_then_insert_v2(hashed_property)
    property = insert_property(hashed_property)
    insert_property_subways(hashed_property[:subway_ids], property) unless property.nil? || hashed_property[:subway_ids].nil? || hashed_property[:subway_ids].empty?
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
        html = fetch_dynamic_page(args.url, args.waiting_cls, args.wait)
      when "Captcha"
        html = fetch_captcha_page(args.url)
      else
        puts "Error"
      end
      card = access_xml_raw(html, args.main_page_cls)
    else
      card = fetch_many_pages(args.url, args.page_nbr, args.main_page_cls)
    end
  end

  def fetch_static_page(url)
    page = Nokogiri::HTML(open(url))
    return page
  end

  def fetch_dynamic_page(url, waiting_class, wait)
    opts = {
      headless: true,
    }
    browser = Watir::Browser.new :chrome, opts
    browser.goto url
    sleep wait
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
      puts "\nAttempt ##{attempt_count} for Scrapping Bee - #{source}"
      res = Net::HTTP.get_response(uri)
      raise ScrappingBeeError unless res.code == "200"
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

  def fetch_many_pages(url, page_nbr, xml_first_page)
    i = 1
    xml = []
    page_nbr.times do
      xml.push(access_xml_raw(fetch_static_page(page_nbr_to_url(url, i)), xml_first_page))
      i += 1
    end
    return xml.flatten
  end

  ###########################
  ## GENERIC LOGIC METHOD  ##
  ###########################

  def page_nbr_to_url(url, page_nbr)
    url.gsub("[[PAGE_NUMBER]]", page_nbr.to_s)
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

  # We loop through a JSON File ISO to the DB to gain performance instead of looping in the entire db
  # We then look in DB the ID of the subway object and assign the id (which is an array, that's odd)
  # And the we send it in an array for insertion.
  def perform_subway_regex(str)
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

  def get_type_flat(str)
    flat_type = "N/C"
    flat_type = "Appartement" if str.downcase.include? "appartement"
    flat_type = "Maison" if str.downcase!.include? "maison"
    return flat_type
  end

  #############################
  ## PUBLIC DATABASE METHODS ##
  #############################

  def is_already_exists(hashed_property)
    response = false
    properties = Property.where(hashed_property.except(:link)).where(
      "created_at >= :seven",
      :seven => Time.now - 7.days,
    )
    response = true if properties.length > 0
    return response
  end

  def is_already_exists_by_link(link)
    response = false
    prop_by_link = Property.where(link: link).where("created_at >= :seven", :seven => Time.now - 7.days)
    response = true if prop_by_link.length > 0
    return response
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

  def is_it_night?
    response = false
    a = Time.parse("22:00:00 +0100")
    b = Time.parse("09:00:00 +0100")
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

  # def insert_property_images(image_array, prop)
  #   image_array.each do |img|
  #     PropertyImage.create(property_id: prop.id, url: img)
  #   end
  #   prop.images.length > 0 ? nil : PropertyImage.create(property: prop)
  # end

  def insert_property_subways(subway_ids, prop)
    subway_ids.each do |subway_id|
      PropertySubway.create(property_id: prop.id, subway_id: subway_id) if PropertySubway.where(property_id: prop.id, subway_id: subway_id).empty?
    end
  end
end
