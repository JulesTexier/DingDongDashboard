class BrokerMailer < ApplicationMailer
  def new_lead(subscriber_id, broker_id)
    @subscriber = Subscriber.find(subscriber_id)
    @broker = Broker.find(broker_id)

    if !@subscriber.nil? && !@broker.nil? 
      subject = "[DING DONG] Nouveau contact"
      mail(from: "etienne@hellodingdong.com", to: @broker.email, subject: subject)
    end

  end
end
