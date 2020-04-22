require "dotenv/load"
require "typhoeus"
require "net/http"
require "uri"
require "json"

class SmsMode
  attr_reader :access_token

  ERROR_FILE = "The specified file does not exist"
  URL = "https://api.smsmode.com/http/1.6/"
  PATH_SEND_SMS = "sendSMS.do"

  def initialize
    @access_token = ENV["SMSMODE_TOKEN"]
  end

  def send_sms_to_broker(lead, broker)
    message = "Un nouveau lead vient de s'inscrire : #{lead.firstname} #{lead.lastname}"
    message += "\u000A> Une nouvelle carte a été crée dans ton Trello"
    send_sms_get(message, [broker.phone], "DingDong", option_stop = "")
  end

  def send_sms_to_team(message)
    team_phone_numbers = Rails.env.production? ? "+33689716569" : "+33689716569, +33624993234, +33786158632"
    send_sms_get(message, team_phone_numbers, "DingDong")
  end

  private

  def send_sms_get(message, destinataires, emetteur, option_stop = "")
    header = { "Content-Type" => "plain/text; charset=ISO-8859-15" }
    params = { :accessToken => @access_token, :message => message.encode(Encoding::ISO_8859_15), :numero => destinataires, :emetteur => emetteur, :stop => option_stop }

    uri = URI.parse(URL + PATH_SEND_SMS)
    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri, header)

    res = http.request(request)
    puts "\n\nSMS SENT - CODE : #{res.code}"
    puts res.body + "\n"
    return res.body
  end
end
