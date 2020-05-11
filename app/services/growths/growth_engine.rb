class GrowthEngine
  attr_reader :json_content, :email_parser, :source, :trigger, :sender_email, :sequence_type
  attr_accessor :first_time_frame, :second_time_frame

  def initialize(json_content, first_time_frame = 48, second_time_frame = 240, sequence_type = "Mail")
    @json_content = json_content
    @first_time_frame = first_time_frame
    @second_time_frame = second_time_frame
    @email_parser = EmailParser.new(@json_content)
    @source = @email_parser.get_value("FromName")
    @sender_email = @email_parser.get_value("To")
    @sequence_type = sequence_type
  end

  def handle_lead
    lead_email = @email_parser.get_reply_to_email
    # 1 • Handle Subscriber (get or create)
    subscriber = get_subscriber(lead_email)
    # 2 • Handle Sequence to execute
    # Est ce qu'on a envoyé une séquence il y a moins de 48h ?
    unless is_sequence_created_in_timeframe?(subscriber, @first_time_frame)
      # Determination de la déquence à lancer !
      ## No sequence has been created in a determined timeframe, therefore we can execute a sequence
      sequence = get_adequate_sequence(subscriber)
      create_subscriber_to_sequence(subscriber, sequence)
      sequence.execute_sequence(subscriber)
    end
  end

  def send_test_email
    mail = GrowthMailer.new_growth_email("adriencoste17@gmail.com","D!ngDong75018")
    byebug    
    mail.deliver_now
  end

  private

  def get_subscriber(email_address)
    Subscriber.where(email: email_address).where.not(status: "duplicates").last.nil? ? Subscriber.create(email: email_address, status: "new_lead") : Subscriber.where(email: email_address).where.not(status: "duplicates").last
  end

  ## If the subscriber has not a sequence, we declare it out of timeframe
  def is_sequence_created_in_timeframe?(subscriber, timeframe)
    subscriber.subscriber_sequences.where("created_at >= ?", Time.now - timeframe.hours).size > 0
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
