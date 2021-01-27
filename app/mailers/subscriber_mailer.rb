class SubscriberMailer < ApplicationMailer
  default :from => "annonces@hellodingdong.com"

  def registration_confirmation(subscriber)
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Confirmation de votre adresse email")
  end

  def stop_confirmation(subscriber)
    @subscriber = subscriber
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Confirmation de la suspension de votre alerte")
  end


  def property_mailer(subscriber, properties)
    @properties = properties
    @subscriber = subscriber
    @links = {profile: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/profile/edit", ads: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/ads" , criterias: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/criterias/edit", broker_meeting: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/funding/estimation" }
    subject = if @properties.length > 1
      "🔔 Plusieurs biens sont sortis à #{@properties.first.created_at.in_time_zone('Europe/Paris').to_s(:time)} le #{@properties.first.created_at.strftime("%d/%m/%Y")}"
    else
      "🔔 Un bien à #{properties.first.price}€ pour #{properties.first.surface}m2 est sorti"
    end
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: subject)
  end

  def good_morning_mailer(subscriber, properties)
    @properties = properties
    @subscriber = subscriber
    @links = {profile: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/profile/edit", ads: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/ads" , criterias: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/criterias/edit", broker_meeting: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/funding/estimation" }
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: "DING DONG - Les biens sortis cette nuit !")
  end

  def welcome_email(subscriber)
    ## last_x_properties returns ids for performance issues
    @properties = Property.find(subscriber.research.last_x_properties(5))
    subject = @properties.length > 1 ? "DING DONG - #{@properties.length} derniers biens !" : "DING DONG - Le dernier bien qui correspond à votre recherche !"
    @subscriber = subscriber
    @links = {profile: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/profile/edit", ads: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/ads" , criterias: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/account/criterias/edit", broker_meeting: "#{ENV["NUXT_URL"]}/subscribers/#{@subscriber.auth_token}/funding/estimation" }
    mail(to: "#{subscriber.firstname} <#{subscriber.email}>", subject: subject)
  end
end
