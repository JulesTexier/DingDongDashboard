require "rails_helper"

RSpec.describe SequenceStep, type: :model do
  describe "testing all logic in sequence_step" do
    before(:all) do
      json_email = File.read("./fixtures/growth_email_type.json")
      @ge = GrowthEngine.new(json_email)
    end
    context "testing respectable_sending_hours" do
      it "should delay sending time" do
        t = DateTime.now.change({ hour: 5 })
        Timecop.freeze(t) do
          @s = FactoryBot.create(:sequence)
          @ss = FactoryBot.create(:sequence_step, time_frame: 0, sequence: @s)
          expect(@ss.respectable_sending_hours(8, 22)).to eq(3)
        end
        t = DateTime.now.change({ hour: 7 })
        Timecop.freeze(t) do
          @s = FactoryBot.create(:sequence)
          @ss = FactoryBot.create(:sequence_step, time_frame: 0, sequence: @s)
          expect(@ss.respectable_sending_hours(8, 22)).to eq(1)
        end
        t = DateTime.now.change({ hour: 23 })
        Timecop.freeze(t) do
          @s = FactoryBot.create(:sequence)
          @ss = FactoryBot.create(:sequence_step, time_frame: 0, sequence: @s)
          expect(@ss.respectable_sending_hours(8, 22)).to eq(9)
        end
      end
    end
  end
end
