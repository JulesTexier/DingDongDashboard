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
      email.push(str.match(/#{email_regex}/i).to_s) if str.match(/#{email_regex}/i).is_a?(MatchData)
    end
    email.uniq.one? ? email.uniq.join : email.uniq
  end

  def get_email_from_value(json_value)
    email_regex = '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,63}'
    res = {}
    res[:email] = []
    self.json_content[json_value].split.each do |str|
      res[:email].push(str.match(/#{email_regex}/i).to_s) if str.match(/#{email_regex}/i).is_a?(MatchData)
    end
    res[:email].uniq
  end

  def get_value(value)
    self.json_content[value]
  end

  def ad_data_parser_se_loger
    rooms_regex = '(\d+)(.?)(pi(è|e)ce(s?))'
    price_regex = '(\d+)(.?)(€)'
    surface_regex = '(\d+)(.?)(\d+)(.?)(m)'
    ad_infos = {}
    html = Nokogiri::HTML.parse(self.json_content["HtmlBody"])
    html.css("tr > td > table.full").each do |data|
      data.text.each_line do |line|
        ad_infos[:rooms_number] = line.match(/#{rooms_regex}/i).to_s.to_int_scrp if line.match(/#{rooms_regex}/i).is_a?(MatchData)
        ad_infos[:price] = line.match(/#{price_regex}/i).to_s.to_int_scrp if line.match(/#{price_regex}/i).is_a?(MatchData)
        ad_infos[:surface] = line.match(/#{surface_regex}/i).to_s.to_float_to_int_scrp if line.match(/#{surface_regex}/i).is_a?(MatchData)
        ad_infos[:ref] = line.gsub("Ref. de l'annonce", "").tr(": \r\n", "") if line.include?("Ref. de l'annonce")
      end
    end
    ad_infos
  end

  # Handle different kinds of trigger according ti source (ref, ad link, ...)
  def get_sequence_trigger
    if @json_content["FromName"] == "SeLoger-Logic"
      return ad_data_parser_se_loger[:ref]
    end
  end
end
