require 'rails_helper'

RSpec.describe Broker, type: :model do
  describe Subscriber do
    describe "model" do

      before :each do
        @am_shift_regular = FactoryBot.create(:broker_shift_morning, day: 1, shift_type: "regular")
        @pm_shift_regular = FactoryBot.create(:broker_shift_afternoon, day: 1, shift_type: "regular")
        @am_shift_subscription = FactoryBot.create(:broker_shift_morning, day: 1, shift_type: "subscription")
        @pm_shift_subscription = FactoryBot.create(:broker_shift_afternoon, day: 1, shift_type: "subscription")
        @broker_am = FactoryBot.create(:broker)
        @broker_pm = FactoryBot.create(:broker)

      end
      
      context "returned adequate Broker shift (in opening hours)" do
        it "should return Regular broker" do
          time = Time.parse("2020-06-01 16:39:20 +0200 ") #lundi, 16h
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_pm)
            expect(Broker.get_current).not_to eq(@broker_am)
          end
        end

        it "should return Subscription broker" do
          time = Time.parse("2020-06-01 16:39:20 +0200 ") #lundi, 16h
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_subscription
            @broker_pm.shifts << @pm_shift_subscription
            expect(Broker.get_current("subscription")).to eq(@broker_pm)
            expect(Broker.get_current("subscription")).not_to eq(@broker_am)
          end
        end
      end

      context "returned adequate Broker shift (out of opening hours)" do
        it "should return tomorrow next BrokerShift" do
          time = Time.parse("2020-05-31 22:39:20 +0200") #dimanche, 22h
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_am)
            expect(Broker.get_current).not_to eq(@broker_pm)
          end
        end
        it "should return today next BrokerShift" do
          time = Time.parse("2020-06-01 02:39:20 +0200") #lundi, 2h du matin
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_am)
            expect(Broker.get_current).not_to eq(@broker_pm)
          end
        end
        it "should return monday next BrokerShift on Friday evening" do
          time = Time.parse("2020-05-29 22:39:20 +0200") #vendredi, 22h 
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_am)
            expect(Broker.get_current).not_to eq(@broker_pm)
          end
        end
        it "should return monday next BrokerShift on Saturday" do
          time = Time.parse("2020-05-30 12:39:20 +0200") #Samedi en journée
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_am)
            expect(Broker.get_current).not_to eq(@broker_pm)
          end
        end
        it "should return monday next BrokerShift on Sunday" do
          time = Time.parse("2020-05-31 12:39:20 +0200") #Dimanche en journée
          Timecop.freeze(time) do 
            @broker_am.shifts << @am_shift_regular
            @broker_pm.shifts << @pm_shift_regular
            expect(Broker.get_current).to eq(@broker_am)
            expect(Broker.get_current).not_to eq(@broker_pm)
          end
        end
      end
      

    end
  end
end
