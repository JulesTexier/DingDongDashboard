class HunterMailer < ApplicationMailer
  def notification_email(hunter_search_id, props)
    @hunter_search = HunterSearch.find(hunter_search_id)
    @props = props
    @url  = 'http://example.com/login'
    mail(from: "nicolas@hellodingdong.com", to: @hunter_search.hunter.email, subject: 'Nouveaux biens ! ')
  end
end
