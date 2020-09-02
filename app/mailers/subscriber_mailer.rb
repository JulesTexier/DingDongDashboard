class SubscriberMailer < ApplicationMailer
  default :from => "etienne@hellodingdong.com"

  def registration_confirmation(subscriber)
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Confirmation de votre adresse email")
  end

  def property_mailer(subscriber, properties)
    @properties = properties
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Nouveaux biens")
  end
  
end
