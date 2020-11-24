require "rails_helper"

RSpec.describe GrowthEngine, type: :service do
  describe "testing all logic in growth_engine" do
    before(:all) do
      @json_email = File.read("./fixtures/growth_email_type.json")
      @agglomeration = FactoryBot.create(:agglomeration, name: "Ile-de-France", ref_code: "PA")
      FactoryBot.create(:broker, agglomeration_id: @agglomeration.id)
      @ge = GrowthEngine.new
    end

    context "testing paramerters" do
      it "should launch and given the fixtures, return specific element" do
        @ge.send(:handle_email, @json_email)
        expect(@ge.source).to eq("SeLoger-Logic")
        expect(@ge.source).to be_a(String)
        expect(@ge.sender_email).to eq("lagencedu17@gmail.com")
        expect(@ge.sender_email).to be_a(String)
        expect(@ge.lead_fullname).to eq("Marikaz Marikaz")
      end
    end

    context "testing logic of handle_lead method" do
      it "should get the customer" do
        @ge.send(:handle_email, @json_email)
        @user = FactoryBot.create(:subscriber, email: "mlesegret@gmail.com", status: "new_lead")
        expect(@ge.send(:get_subscriber, @ge.lead_email, @agglomeration.id)).to eq(@user)
      end

      it "should create a customer if its not in db" do
        expect(@ge.send(:get_subscriber, "new_customer@customer.com", @agglomeration.id)).to eq(Subscriber.where(email: "new_customer@customer.com", status: "new_lead").last)
      end
    end

    context "testing is sequence_created_in_timeframe?" do
      before(:each) do
        @subscriber = FactoryBot.create(:subscriber, email: "sub@sub.com", status: "new_lead")
        @sequence = FactoryBot.create(:sequence)
        @client_subscriber = FactoryBot.create(:subscriber, email: "client@sub.com", status: "onboarded")
      end
      #### NEW_LEAD ####
      it "should return false if it's a new customer because it doesnt have subscriber_sequence" do
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, @ge.first_time_frame)).to eq(false)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 10)).to eq(false)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 1)).to eq(false)
      end

      it "should return true if it's a new customer but it does have a subscriber_sequence in first_time_frame" do
        FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @subscriber)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, @ge.first_time_frame)).to eq(true)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 10)).to eq(true)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 1)).to eq(true)
      end

      it "should return true if it's a new customer but it does have a subscriber_sequence in second_time_frame" do
        FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @subscriber)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, @ge.second_time_frame)).to eq(true)
      end

      #### CLIENT LEAD ####
      it "should return false if it's a client but it doesnt have a subscriber_sequence in first_time_frame" do
        expect(@ge.send(:is_sequence_created_in_timeframe?, @client_subscriber, @ge.first_time_frame)).to eq(false)
      end

      it "should return false if it's a client, have a subscriber_sequence but outside first_time_frame" do
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @client_subscriber, created_at: 12.days.ago)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @client_subscriber, @ge.first_time_frame)).to eq(false)
      end

      it "should return false if it's a client, have a subscriber_sequence but outside second_time_frame" do
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @client_subscriber, created_at: 43.days.ago)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @client_subscriber, @ge.second_time_frame)).to eq(false)
      end

      it "should return true if it's a client, have a subscriber_sequence but inside first_time_frame" do
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @client_subscriber)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @client_subscriber, @ge.first_time_frame)).to eq(true)
      end

      it "should return true if it's a client, have a subscriber_sequence but inside second_time_frame" do
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @client_subscriber)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @client_subscriber, @ge.second_time_frame)).to eq(true)
      end
    end

    context "testing is get_adequate_sequence?" do
      before(:each) do
        @sequence_hack = FactoryBot.create(:sequence, marketing_type: "hack")
        @sequence_regular = FactoryBot.create(:sequence, marketing_type: "regular")
      end

      it "should return sequence regular if subscriber is client and active" do
        @client = FactoryBot.create(:subscriber, is_active: true, status: "onboarded")
        expect(@ge.send(:get_adequate_sequence, @client)).to eq(@sequence_regular)
      end

      it "should return sequence hack if subscriber is client and inactive" do
        @client = FactoryBot.create(:subscriber, is_active: false, status: "onboarded")
        expect(@ge.send(:get_adequate_sequence, @client)).to eq(@sequence_hack)
      end

      it "should return sequence hack if subscriber is not client and doesnt have subscriber_sequence in second_timeframe" do
        @new_lead = FactoryBot.create(:subscriber, status: "new_lead")
        # FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @new_lead)
        expect(@ge.send(:get_adequate_sequence, @new_lead)).to eq(@sequence_hack)
      end

      it "should return sequence hack if subscriber is not client and doesnt have subscriber_sequence in second_timeframe" do
        @new_lead = FactoryBot.create(:subscriber, status: "new_lead")
        FactoryBot.create(:subscriber_sequence, sequence: @sequence_hack, subscriber: @new_lead)
        expect(@ge.send(:get_adequate_sequence, @new_lead)).to eq(@sequence_regular)
      end
    end
    context "testing is handle_lead growth engine time_frame" do
      before(:each) do
        @new_lead_subscriber = FactoryBot.create(:subscriber, status: "new_lead", email: "mlesegret@gmail.com")
        @client_subscriber = FactoryBot.create(:subscriber, status: "onboarded", email: "client@sub.com", is_active: true)
        @sequence_regular = FactoryBot.create(:sequence, marketing_type: "regular")
        @sequence_hack = FactoryBot.create(:sequence, marketing_type: "hack")
      end

      ## On a créé une séquence il y a moins de 48h, on vérifie qu'on renvoie pas une séquence
      it "shouldnt create new sequence because a sequence has been created in first_time_frame" do
        @subscriber_to_sequence = FactoryBot.create(:subscriber_sequence, sequence: @sequence_hack, subscriber: @new_lead_subscriber, created_at: 1.days.ago)
        @ge.send(:handle_lead_email, @new_lead_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(1)
      end

      ## On a crée une séquence il y a plus de 48h et moins de 10 jours, on doit donc envoyer une séquence régulière
      it "is a new lead with a a sequence created 3 days ago so we return a regular sequence " do
        @subscriber_to_sequence = FactoryBot.create(:subscriber_sequence, sequence: @sequence_hack, subscriber: @new_lead_subscriber, created_at: 3.days.ago)
        @ge.send(:handle_lead_email, @new_lead_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(2)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_regular)
      end

      ## C'est un nouveau lead qui n'a pas de séquence, ca doit envoyer le hack
      it "is a new lead with no sequences so we sent a hack" do
        @ge.send(:handle_lead_email, @new_lead_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(1)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_hack)
      end

      ## C'est un client actif de Ding Dong donc on lui envoie une séquence régulière quoiqu'il
      it "is an active client so we return a regular sequence" do
        @ge.send(:handle_lead_email, @client_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(1)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_regular)
      end

      ## C'est un client inactif de Ding Dong donc on lui envoie une séquence hack quoiqu'il
      it "is an inactive client so we send a hack sequence" do
        @client_subscriber.update(is_active: false)
        @ge.send(:handle_lead_email, @client_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(1)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_hack)
      end

      ## C'est un new_lead qui nous contacte 11 jours après sa dernière séquence, on lui renvoie un hack
      it "is a new lead that contacts us 11 days ago so we should return hack sequence" do
        @subscriber_to_sequence = FactoryBot.create(:subscriber_sequence, sequence: @sequence_hack, subscriber: @new_lead_subscriber, created_at: 43.days.ago)
        @ge.send(:handle_lead_email, @new_lead_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(2)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_hack)
      end

      ## C'est un new_lead qui nous contacte 11 jours puis 8 jours après sa dernière séquence, on lui renvoie un regular
      it "is a new lead that contact us 11 days then 8 days ago so we should return regular sequence" do
        @subscriber_to_sequence = FactoryBot.create(:subscriber_sequence, sequence: @sequence_hack, subscriber: @new_lead_subscriber, created_at: 11.days.ago)
        @subscriber_to_sequence_2 = FactoryBot.create(:subscriber_sequence, sequence: @sequence_regular, subscriber: @new_lead_subscriber, created_at: 8.days.ago)
        @ge.send(:handle_lead_email, @new_lead_subscriber.email)
        expect(SubscriberSequence.all.count).to eq(3)
        expect(SubscriberSequence.last.sequence).to eq(@sequence_regular)
      end
    end
  end
end
