class BrokerManager::LoanManager::CreateSubscriberNote < ApplicationService

  def initialize(subscriber_id, notes_attributes)
    @subscriber = Subscriber.find(subscriber_id)
    @notes_attributes = notes_attributes
  end

  def call
    content = "SIMULATION DE FINANCEMENT :&#10 - " + @notes_attributes.map{|item| "#{item[:label]} : #{item[:value]} #{item[:unit]}"}.join(" :&#10 ").to_s
    SubscriberNote.create(subscriber: @subscriber, content: content)
  end

end