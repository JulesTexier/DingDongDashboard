class GrowthEngine
  attr_reader :source, :sender_email, :lead_email, :property_data
  attr_accessor :first_time_frame, :second_time_frame

  def initialize(first_time_frame = 42, second_time_frame = 1008)
    @first_time_frame = first_time_frame
    @second_time_frame = second_time_frame
  end

  def perform_email_webhook(json_content)
    email_data = handle_email(json_content)
    handle_lead_email(email_data) unless Sequence.where(sender_email: email_data[:sender_email], source: email_data[:source]).empty?
  end

  private

  def handle_email(json_content)
    e = EmailParser.new(json_content)
    d = { 
          source: e.get_value("FromName"),
          sender_email: e.get_value("To"),
          sub_email: e.get_reply_to_email,
          property_data: e.ad_data_parser_se_loger
        }
  end

  def handle_lead_email(email_data)
    # 1 • Handle Subscriber (get or create)
    subscriber = get_subscriber(email_data[:sub_email], email_data[:property_data])
    # 2 • Handle Sequence to execute
    # Est ce qu'on a envoyé une séquence il y a moins de 48h ?
    if !is_sequence_created_in_timeframe?(subscriber, @first_time_frame)
      # Determination de la déquence à lancer !
      ## No sequence has been created in a determined timeframe, therefore we can execute a sequence
      sequence = get_adequate_sequence(subscriber)
      create_subscriber_to_sequence(subscriber, sequence)
      sequence.execute_sequence(subscriber, email_data[:property_data])
    end
  end

  def get_subscriber(email_address)
    sub = Subscriber.where(email: email_address).last
    if sub.nil?
      sub = Subscriber.new(email: email_address, status: "new_lead")
      # Research.create()
      sub.save(validate: false)
    end
    sub
  end

  ## If the subscriber has not a sequence, we declare it out of timeframe
  def is_sequence_created_in_timeframe?(subscriber, timeframe)
    !subscriber.subscriber_sequences.empty? && subscriber.subscriber_sequences.last.created_at >= timeframe.hours.ago
  end

  def get_adequate_sequence(subscriber)
    if subscriber.status != "new_lead" && subscriber.is_active
      ## If the sub is a client and is active
      ## we execute a regular sequence
      marketing_type = "regular"
    else
      ## If the sub is not a client, or is an inactive client, we want to make some publicity for dingdong
      marketing_type = is_sequence_created_in_timeframe?(subscriber, @second_time_frame) ? "regular" : "hack"
    end
    Sequence.get_adequate_sequence(marketing_type, @source, @sender_email)
  end

  def create_subscriber_to_sequence(subscriber, sequence)
    SubscriberSequence.create(subscriber: subscriber, sequence: sequence)
  end
end
