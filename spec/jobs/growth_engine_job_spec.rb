require 'rails_helper'

RSpec.describe GrowthEngineJob, type: :job do
  describe "#perform_later" do
    before :all do
      @subscriber = FactoryBot.create(:subscriber, status: 'new_lead')
      @sequence = FactoryBot.create(:sequence, marketing_type: 'hack')
      @sequence_step = FactoryBot.create(:sequence_step, sequence: @sequence, step_type: "shoot_mail", time_frame: 10)
    end
    it "enqueue job" do
      ActiveJob::Base.queue_adapter = :test
      expect {
      GrowthEngineJob.perform_later(@sequence_step.id, @subscriber.id)
      }.to have_enqueued_job
      time =  Time.now.to_date + @sequence_step.time_frame.hour
      Timecop.freeze(time) do 
        expect {
          GrowthEngineJob.set(wait_until: time).perform_later(@sequence_step.id, @subscriber.id)
        }.to have_enqueued_job.with(@sequence_step.id, @subscriber.id).on_queue("mailers").at(time)
      end
    end
  end
end
