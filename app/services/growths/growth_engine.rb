class GrowthEngine

    attr_reader :json_content
    attr_accessor :first_time_frame, :second_time_frame

    def initialize(json_content, first_time_frame = 48 , second_time_frame = 240)
      @json_content = json_content
      @first_time_frame = first_time_frame
      @second_time_frame = second_time_frame
    end

    def handle_lead
      parser = EmailParser.new(json_content)
      lead_email = parser.get_reply_to_email

      # 1 • Check if email is in DB
      subscriber = get_subscriber(lead_email)

      # Est ce qu'on a envoyé une séquence il y a moins de 48h ?
      if !is_in_sequence_timeframe?(subscriber, @first_time_frame)
        # Determination de la déquence à lancer !
        sequence = get_adequate_sequence(subscriber)
        sequence.execute(subscriber)
      end
    end

    private

    def get_subscriber(email_address)
      s = Subscriber.where(email: email_address).last.nil? ?  Subscriber.create(email: email_address, status: "new_lead") :  Subscriber.where(email: email_address).last
    end

    def is_in_sequence_timeframe?(subscriber, timeframe)
      SubscriberSequence.where(subscriber: subscriber).last.created_at >= Time.now - timeframe.to_i.hours
    end

    def get_adequate_sequence(subscriber)
      if subscriber.is_client? && subscriber.is_active 
         Sequence.find_by(name: "regular")
      else 
        is_in_sequence_timeframe?(subscriber, @second_time_frame) ? Sequence.find_by(name: "regular") : Sequence.find_by(name: "se_loger_hack")
      end
    end




end