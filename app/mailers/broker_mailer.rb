class BrokerMailer < ApplicationMailer  
  def new_lead(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    @broker = @subscriber.broker

    if !@subscriber.nil? && !@broker.nil? 
      subject = "[DING DONG] Nouveau contact"
      if Rails.env == "development"
        mail(from: "etienne@hellodingdong.com", to: "greg@hellodingdong.com", subject: subject)
      else 
        mail(from: "etienne@hellodingdong.com", to: @broker.email, subject: subject)
      end
    end
  end

  def weekly_update
    # @subscribers = Subscriber.find(subscribers_id)
    # @recent_leads = @subscribers.where('created_at > ?', Time.now - )
    mail(from: "etienne@hellodingdong.com", to: "f.bonnand@gmail.com", subject: "DING DONG - Synthèse de la semaine")
  end
end
