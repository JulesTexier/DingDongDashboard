# coding: utf-8
class EmailParser
  attr_reader :json_content

  def initialize(json_response)
    @json_content = JSON.parse(json_response)
  end

  def get_reply_to_email
    email_regex = '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,63}'
    email = []
    self.json_content["ReplyTo"].split.each do |str|
      email.push(str.match(/#{email_regex}/i).to_s) if str.match?(/#{email_regex}/i)
    end
    email.uniq.one? ? email.uniq.join : email.uniq
  end

  def get_phone_number
    phone_regex = 'tel:[0-9]{10}'
    phone = []
    self.json_content["HtmlBody"].split.each do |str|
      phone.push(str.match(/#{phone_regex}/i).to_s.gsub('tel:','')) if str.match?(/#{phone_regex}/i)
    end
    phone.uniq.one? ? phone.uniq.join : phone.uniq
  end

  def get_email_from_value(json_value)
    email_regex = '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,63}'
    res = { email: [] }
    self.json_content[json_value].split.each do |str|
      res[:email].push(str.match(/#{email_regex}/i).to_s) if str.match?(/#{email_regex}/i)
    end
    res[:email].uniq
  end

  def get_value(value)
    self.json_content[value]
  end

  def get_agglomeration_id(str)
    area_str = str.split("Appartement")[0]
    area_str = str.split("Maison")[0] if area_str.empty?
    area = Area.where('name LIKE ?', "%" + area_str.downcase.capitalize + "%")
    area.empty? ? nil : area.first.department.agglomeration.id
  end

  def get_reference
    ref_regex = "Ref. de l'annonce  : [A-Z]{2}[0-9]{4}[A-Z]{2}"
    ref = self.json_content["TextBody"].match(/#{ref_regex}/i).to_s if self.json_content["TextBody"].match?(/#{ref_regex}/i)
    ref = ref.gsub("Ref. de l'annonce  : ", "")
  end

  def ad_data_parser_se_loger
    rooms_regex = '(\d+)(.?)(pi(è|e)ce(s?))'
    price_regex = '(\d+)(.?)(€)'
    surface_regex = '(\d+)(.?)(\d+)(.?)(m)'
    
    ad_infos = {}
    html = Nokogiri::HTML.parse(self.json_content["HtmlBody"])
    html.css("tr > td > table.full").each do |data|
      data.text.each_line do |line|
        ad_infos[:agglomeration_id] = get_agglomeration_id(line) if line.include?("Appartement") || line.include?("Maison")
        ad_infos[:rooms_number] = line.match(/#{rooms_regex}/i).to_s.to_int_scrp if line.match?(/#{rooms_regex}/i)
        ad_infos[:price] = line.to_int_scrp if line.match?(/#{price_regex}/i)
        ad_infos[:surface] = line.match(/#{surface_regex}/i).to_s.to_float_to_int_scrp if line.match?(/#{surface_regex}/i)
        ad_infos[:ref] = line.gsub("Ref. de l'annonce", "").tr(": \r\n", "") if line.include?("Ref. de l'annonce")
      end
    end
    ad_infos
  end

  # Handle different kinds of trigger according ti source (ref, ad link, ...)
  def get_sequence_trigger
    if @json_content["FromName"] == "SeLoger-Logic"
      ad_data_parser_se_loger[:ref]
    end
  end
end
