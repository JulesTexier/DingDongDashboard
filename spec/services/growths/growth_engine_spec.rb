require "rails_helper"

RSpec.describe GrowthEngine, type: :service do
  describe "testing all logic in growth_engin" do
    before(:all) do
      json_email = File.read("./fixtures/growth_email_type.json")
      @ge = GrowthEngine.new(json_email)
    end

    context "testing paramerters" do
      it "should launch and given the fixtures, return specific element" do
        expect(@ge.source).to eq("SeLoger-Logic")
        expect(@ge.source).to be_a(String)
        expect(@ge.sender_email).to eq("lagencedu17@gmail.com")
        expect(@ge.sender_email).to be_a(String)
      end
    end

    context "testing logic of handle_lead method" do
      it "should get the customer" do
        @user = FactoryBot.create(:subscriber, email: "mlesegret@gmail.com", status: "new_lead")
        expect(@ge.send(:get_subscriber, @ge.email_parser.get_reply_to_email)).to eq(@user)
      end

      it "should create a customer if its not in db" do
        expect(@ge.send(:get_subscriber, "new_customer@customer.com")).to eq(Subscriber.where(email: "new_customer@customer.com", status: "new_lead").last)
      end
    end

    context "testing is sequence_created_in_timeframe?" do
      before(:each) do
        @subscriber = FactoryBot.create(:subscriber, email: "sub@sub.com")
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
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @client_subscriber, created_at: 12.days.ago)
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
  end
end
