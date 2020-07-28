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
end
