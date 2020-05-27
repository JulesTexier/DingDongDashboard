require "rails_helper"

RSpec.describe SequenceStep, type: :model do
  describe "testing all logic in sequence_step" do
    before(:all) do
      @json_email = File.read("./fixtures/growth_email_type.json")
      @ge = GrowthEngine.new
      @s_hack = FactoryBot.create(:sequence, marketing_type: "hack")
      @ss1 = FactoryBot.create(:sequence_step, time_frame: 0, sequence: @s_hack, step: 1, subject: "test1", content: "mail1")
      @ss2 = FactoryBot.create(:sequence_step, time_frame: 21, sequence: @s_hack, step: 2, subject: "test2", content: "mail2")
    end
    context "testing respectable_sending_hours" do
      it "should delay sending time" do
        t = DateTime.now.change({ hour: 1 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(7)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(21)
        end
        t = DateTime.now.change({ hour: 2 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(6)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(21)
        end
        t = DateTime.now.change({ hour: 3 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(5)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(29)
        end
        t = DateTime.now.change({ hour: 4 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(4)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(28)
        end
        t = DateTime.now.change({ hour: 5 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(3)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(27)
        end
        t = DateTime.now.change({ hour: 7 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(1)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(25)
        end
        t = DateTime.now.change({ hour: 9 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(0)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(23)
        end
        t = DateTime.now.change({ hour: 23 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(0)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(21)
        end
        t = DateTime.now.change({ hour: 4 })
        Timecop.freeze(t) do
          expect(@ss1.respectable_sending_hours(8, 23)).to eq(4)
          expect(@ss2.respectable_sending_hours(8, 23)).to eq(28)
        end
      end
    end
  end
end
