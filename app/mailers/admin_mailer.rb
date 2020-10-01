class AdminMailer < ApplicationMailer

  def subscriber_email_stop(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    mail(to: "etienne@hellodingdong.com", subject: "[ALERTE STOP] - #{@subscriber.firstname} vient de stopper son alerte email")
  end

  def subscriber_email_reactivation(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    mail(to: "etienne@hellodingdong.com", subject: "[ALERTE REACTIVEE] - #{@subscriber.firstname} vient de réactiver son alerte email")
  end

  def subscriber_funding_question(subscriber_id, question_category, question_content)
    @subscriber = Subscriber.find(subscriber_id)
    @question_category = question_category
    @question_content = question_content
    mail(to: "etienne@hellodingdong.com", subject: "[FINANCEMENT] - Question à propos de : #{question_category}")
  end

end
