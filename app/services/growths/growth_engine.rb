class GrowthEngine
  attr_reader :source, :sender_email, :sequence_type, :lead_email
  attr_accessor :first_time_frame, :second_time_frame

  def initialize(first_time_frame = 48, second_time_frame = 240, sequence_type = "Mail")
    @first_time_frame = first_time_frame
    @second_time_frame = second_time_frame
    @sequence_type = sequence_type
  end

  def perform_email_webhook(json_content)
    handle_email(json_content)
    handle_lead_email(@lead_email)
  end

  private

  def handle_email(json_content)
    email_parser = EmailParser.new(json_content)
    @source = email_parser.get_value("FromName")
    @sender_email = email_parser.get_value("To")
    @lead_email = email_parser.get_reply_to_email
  end

  def handle_lead_email(email)
    # 1 • Handle Subscriber (get or create)
    subscriber = get_subscriber(email)
    # 2 • Handle Sequence to execute
    # Est ce qu'on a envoyé une séquence il y a moins de 48h ?
    if !is_sequence_created_in_timeframe?(subscriber, @first_time_frame)
      # Determination de la déquence à lancer !
      ## No sequence has been created in a determined timeframe, therefore we can execute a sequence
      sequence = get_adequate_sequence(subscriber)
      create_subscriber_to_sequence(subscriber, sequence)
      sequence.execute_sequence(subscriber)
    end
  end

  def get_subscriber(email_address)
    Subscriber.where(email: email_address).where.not(status: "duplicates").last.nil? ? Subscriber.create(email: email_address, status: "new_lead") : Subscriber.where(email: email_address).where.not(status: "duplicates").last
  end

  ## If the subscriber has not a sequence, we declare it out of timeframe
  def is_sequence_created_in_timeframe?(subscriber, timeframe)
    !subscriber.subscriber_sequences.empty? && subscriber.subscriber_sequences.last.created_at >= timeframe.hours.ago
  end

  def get_adequate_sequence(subscriber)
    if subscriber.is_client? && subscriber.is_active
      ## If the sub is a client and is active
      ## we execute a regular sequence
      marketing_type = "regular"
    else
      ## If the sub is not a client, or is an inactive client, we want to make some publicity for dingdong
      marketing_type = is_sequence_created_in_timeframe?(subscriber, @second_time_frame) ? "regular" : "hack"
    end
    Sequence.get_adequate_sequence(marketing_type, @source, @sender_email, @sequence_type)
  end

  def create_subscriber_to_sequence(subscriber, sequence)
    SubscriberSequence.create(subscriber: subscriber, sequence: sequence)
  end
end
