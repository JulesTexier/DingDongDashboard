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
        @sequence_step = FactoryBot.create(:sequence_step, sequence: @sequence)
        @sequence_subscriber = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @subscriber)
      end
      it "should return true if timeframe is inferior as subscriber_sequence timeframe" do
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, @ge.first_time_frame)).to eq(true)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 10)).to eq(true)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber, 1)).to eq(true)
      end

      it "should return false if timeframe is superior as subscriber_sequence timeframe" do
        @subscriber_already_client = FactoryBot.create(:subscriber, email: "sub2@sub.com")
        @sequence_subscriber_already_client = FactoryBot.create(:subscriber_sequence, sequence: @sequence, subscriber: @subscriber_already_client, created_at: 2.days.ago)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber_already_client, @ge.first_time_frame)).to eq(false)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber_already_client, 10)).to eq(false)
        expect(@ge.send(:is_sequence_created_in_timeframe?, @subscriber_already_client, 1)).to eq(false)
      end
    end
  end
end
