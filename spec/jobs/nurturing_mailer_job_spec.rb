require 'rails_helper'

RSpec.describe NurturingMailerJob, type: :job do
  describe "#perform_later" do
    before :all do
      ActiveJob::Base.queue_adapter = :test
      @subscriber = FactoryBot.create(:subscriber)
      agglomeration = FactoryBot.create(:agglomeration)
      FactoryBot.create(:subscriber_research, subscriber: @subscriber, agglomeration: agglomeration)
      @nurturing_email = FactoryBot.create(:nurturing_mailer, time_frame: 0, template: "template_1")
    end

    it "enqueue job" do
      expect {
      NurturingMailerJob.perform_later(@subscriber, @nurturing_email)
      }.to have_enqueued_job
      time =  Time.now.to_date + @nurturing_email.time_frame.hour
      Timecop.freeze(time) do 
        expect {
          NurturingMailerJob.set(wait_until: time).perform_later(@subscriber, @nurturing_email)
        }.to have_enqueued_job.with(@subscriber, @nurturing_email).on_queue("mailers").at(time)
      end
    end
  end
end
