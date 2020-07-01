class HunterMailer < ApplicationMailer
  def notification_email(hunter_search_id, props)
    @hunter_search = HunterSearch.find(hunter_search_id)
    @props = props
    subject = props.size > 1 ? "Nouveaux biens" : "Nouveau bien"
    mail(from: "nicolas@hellodingdong.com", to: @hunter_search.hunter.email, subject: subject)
  end
end
