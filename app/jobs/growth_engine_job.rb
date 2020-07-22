class GrowthEngineJob < ApplicationJob
  queue_as :default

  def perform(*args)
    sequence_step = SequenceStep.find(args[0])
    subscriber = Subscriber.find(args[1])
    property_data = args[2]

    if !sequence_step.nil? && !subscriber.nil?
      # 1 • Add a SubscriberStatus 
      SubscriberStatus.create(subscriber: subscriber, status: Status.find_by(name: sequence_step.get_status_name))

      # 2 • Send email 
      GrowthMailer.send_growth_email_gmail(sequence_step, subscriber, property_data).deliver_now if sequence_step.step_type == "shoot_mail"
    end
  end
end
