class GrowthEngineJob < ApplicationJob
  queue_as :default

  def perform(*args)
    sequence = Sequence.find(sequence_id)
    subscriber = Sequence.find(subscriber_id)

    # 1 • Add a SubscriberStatus 
    SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name: sequence.get_status_name))

    # 2 • Send email 
    GrowthMailer.send_growth_email_gmail(sequence, subscriber).deliver_now
  end
end
