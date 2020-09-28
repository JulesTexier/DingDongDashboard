class AdminMailer < ApplicationMailer

  def subscriber_email_stop(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    mail(to: "etienne@hellodingdong.com", subject: "[ALERTE STOP] - #{@subscriber.firstname} vient de stopper son alerte email")
  end
end
