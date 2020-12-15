class BrokerJob < ApplicationJob
  queue_as :mailers

  def perform(*args)
    begin
      subscriber = Subscriber.find(args[0])
      BrokerMailer.new_hot_lead(args[0]).deliver_now if subscriber.hot_lead
    rescue ActiveRecord::RecordNotFound => e
      puts e      
    end
  end

end
