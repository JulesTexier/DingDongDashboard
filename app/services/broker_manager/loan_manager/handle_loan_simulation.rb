class BrokerManager::LoanManager::HandleLoanSimulation < ApplicationService

  def initialize(subscriber_id, notes_attributes)
    @subscriber = Subscriber.find(subscriber_id)
    @notes_attributes = notes_attributes
  end

  def call
    @subscriber.update(hot_lead: true)
    BrokerManager::LoanManager::CreateSubscriberNote.call(@subscriber.id, @notes_attributes)
    BrokerMailer.new_hot_lead(@subscriber.id, @notes_attributes).deliver_now
  end

end