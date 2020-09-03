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

  def welcome_email(subscriber)
    ## last_x_properties returns ids for performance issues
    @properties = Property.find(subscriber.research.last_x_properties(5))
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - 5 derniers biens !")
  end
end
