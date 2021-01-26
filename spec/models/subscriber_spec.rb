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

  describe "professionnal attribution" do 
    before(:each) do 
      agglomeration = FactoryBot.create(:agglomeration)
      broker_agency = FactoryBot.create(:broker_agency, agglomeration_id: agglomeration.id)
      broker = FactoryBot.create(:broker, email: 'etienne@hellodingdong.com', broker_agency_id: broker_agency.id)
      broker.update(agglomeration: agglomeration)
      FactoryBot.create(:notary)
      FactoryBot.create(:contractor)
      @subscriber = FactoryBot.create(:subscriber, broker: nil, contractor: nil, notary: nil)
      @research = FactoryBot.create(:subscriber_research, subscriber: @subscriber, agglomeration: agglomeration)
      @research.areas << FactoryBot.create(:area, department: FactoryBot.create(:department, agglomeration: agglomeration))
      @subscriber.send(:professional_attribution)
    end
    it "should associate a broker" do 
      expect(@subscriber.broker).to be_a(Broker)
      expect(@subscriber.broker).not_to be(nil)
    end
    it "should associate a notary" do 
      expect(@subscriber.notary).to be_a(Notary)
      expect(@subscriber.notary).not_to be(nil)
    end
    it "should associate a contractor" do 
      expect(@subscriber.contractor).to be_a(Contractor)
      expect(@subscriber.contractor).not_to be(nil)
    end
  end

  describe "validate_email + execute_nurturing_email" do 
    before(:each) do 
      ActiveJob::Base.queue_adapter = :test
      @subscriber = FactoryBot.create(:subscriber, 
        email_confirmed: false, 
        confirm_token: "bullshit_token", 
        messenger_flux: false, 
        email_flux: true,
        is_active: false)
      @nurturing_mailer = FactoryBot.create(:nurturing_mailer, is_active: true)
    end
    it "should set correct attributes" do 
      @subscriber.validate_email
      expect(@subscriber.is_active).to eq(true)
      expect(@subscriber.confirm_token).to eq(nil)
      expect(@subscriber.confirm_token).not_to eq("bullshit_token")
      expect(@subscriber.email_confirmed).to eq(true)
    end
    
    it "should incremenent enqueued jobs by one" do 
      @subscriber.validate_email
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq(1)
    end

    it "shouldnt incremenent enqueued jobs by one because subs isnt validated" do 
      @subscriber.execute_nurturing_mailer
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).not_to eq(1)
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq(0)
    end

    it "should incremenent enqueued jobs by ten" do 
      10.times do 
        i = 0
        FactoryBot.create(:nurturing_mailer, is_active: true, time_frame: i, template: "template_test_#{i}")
        i += 1
      end
      @subscriber.validate_email
      expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to eq(11) #and not 10 because theres already a nurturing email in db
    end
  end
end
