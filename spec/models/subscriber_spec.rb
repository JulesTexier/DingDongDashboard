require "rails_helper"

RSpec.describe Subscriber, type: :model do
  describe Subscriber do
    describe "model" do
      it "has a valid factory" do
        expect(build(:subscriber_dummy_fb_id)).to be_valid
      end
    end
  end

  describe "active_and_not_blocked" do
    it "should return proper number of subscriber, which is one" do
      subscriber = FactoryBot.create(:subscriber, is_blocked: false, is_active: true)
      expect(Subscriber.active_and_not_blocked.count).to eq(1)
    end

    it "should return proper number of subscriber, which is one" do
      subscriber = FactoryBot.create(:subscriber, is_blocked: nil, is_active: true)
      expect(Subscriber.active_and_not_blocked.count).to eq(1)
    end

    it "should return proper number of subscriber, which is one" do
      subscriber = FactoryBot.create(:subscriber, is_blocked: true, is_active: false)
      expect(Subscriber.active_and_not_blocked.count).to eq(0)
    end

    it "should return proper number of subscriber, which is one" do
      subscriber = FactoryBot.create(:subscriber, is_blocked: nil, is_active: false)
      expect(Subscriber.active_and_not_blocked.count).to eq(0)
    end
  end
end
