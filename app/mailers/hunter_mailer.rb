class HunterMailer < ApplicationMailer
  def notification_email(hunter_research_id, props)
    @hunter_research = Research.find(hunter_research_id)
    @props = props
    subject = props.size > 1 ? "Nouveaux biens" : "Nouveau bien"
    mail(from: "nicolas@hellodingdong.com", to: @hunter_research.hunter.email, subject: subject)
  end
end
