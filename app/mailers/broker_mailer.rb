class BrokerMailer < ApplicationMailer
  def new_lead(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    @broker = @subscriber.broker

    if !@subscriber.nil? && !@broker.nil? 
      subject = "[DING DONG] Nouveau contact"
      mail(from: "etienne@hellodingdong.com", to: @broker.email, subject: subject)
      # mail(from: "etienne@hellodingdong.com", to: "fred@hellodingdong.com", subject: subject)
    end

  end
end
