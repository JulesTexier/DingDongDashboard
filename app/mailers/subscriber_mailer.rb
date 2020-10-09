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

  def good_morning_mailer(subscriber, properties)
    @properties = properties
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Les biens tombés cette nuit !")
  end

  def welcome_email(subscriber)
    ## last_x_properties returns ids for performance issues
    @properties = Property.find(subscriber.research.last_x_properties(5))
    subject = @properties.length > 1 ? "DING DONG - #{@properties.length} derniers biens !" : "DING DONG - Le dernier bien correspondant à votre recherche !"
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: subject)
  end
end
