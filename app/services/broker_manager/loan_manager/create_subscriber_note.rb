class BrokerManager::LoanManager::CreateSubscriberNote < ApplicationService

  def initialize(subscriber_id, notes_attributes)
    @subscriber = Subscriber.find(subscriber_id)
    @notes_attributes = notes_attributes
  end

  def call
    attributes = @notes_attributes.each{|k, v| "#{k} : #{v} :&#10"}.flatten[0].to_s
    content = "SIMULATION DE FINANCEMENT :&#10" + attributes

              puts content
    # SubscriberNote.create(subscriber: @subscriber, content: content)
  end

end