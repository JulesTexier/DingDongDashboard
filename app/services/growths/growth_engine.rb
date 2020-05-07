class GrowthEngine

    attr_reader :json_content
    attr_accessor :first_time_frame, :second_time_frame

    def initialize(json_content, first_time_frame = 48 , second_time_frame = 240)
      @json_content = json_content
      @first_time_frame = first_time_frame
      @second_time_frame = second_time_frame
      @email_parser = EmailParser.new(@json_content)
      @source = JSON.parse(@json_content)["FromName"]
      @trigger = parser.get_sequence_trigger
    end

    def handle_lead
      lead_email = @email_parser.get_reply_to_email
      # 1 • Handle Subscriber (get or create)
      subscriber = get_subscriber(lead_email)
      # 2 • Handle Sequence to execute 
      # Est ce qu'on a envoyé une séquence il y a moins de 48h ?
      if !is_in_sequence_timeframe?(subscriber, @first_time_frame)
        # Determination de la déquence à lancer !
        sequence = get_adequate_sequence(subscriber)
        sequence.execute(subscriber)
      end
    end

    private

    def get_subscriber(email_address)
      s = Subscriber.where(email: email_address).where.not(status: "duplicates").last.nil? ?  Subscriber.create(email: email_address, status: "new_lead") :  Subscriber.where(email: email_address).where.not(status: "duplicates").last
    end

    def is_in_sequence_timeframe?(subscriber, timeframe)
      SubscriberSequenceEmail.where(subscriber: subscriber).last.created_at >= Time.now - timeframe.to_i.hours
    end

    def get_adequate_sequence(subscriber)
      if subscriber.is_client? && subscriber.is_active 
         SequenceEmail.find_by(name: "regular")
      else 
        is_in_sequence_timeframe?(subscriber, @second_time_frame) ? Sequence.find_by(name: "regular") : Sequence.find_by(name: "se_loger_hack")
      end
    end




end