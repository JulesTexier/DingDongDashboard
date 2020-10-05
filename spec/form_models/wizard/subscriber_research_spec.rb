require 'rails_helper'

RSpec.describe Wizard::SubscriberResearch::Base, type: :model do
  subject { Wizard::SubscriberResearch::Base.new({ min_floor: 2, max_price: 1000000 }, 
  {firstname: "Maxime", lastname: "Le Segretain", email: "mlesegret@gmail.com", phone: "0689716569"}) }

  describe '#subscriber_research' do
    it 'returns the User instance' do
      expect(subject.subscriber_research).to be_a(Research)
    end
  end

  describe 'delegate user attributes' do
    it 'delegates the user attributes to the user instance' do
      subject.min_floor = 2
      subject.max_price = 1000000
      expect(subject.subscriber_research.min_floor).to eq(2)
      expect(subject.subscriber_research.max_price).to eq(1000000)
    end
  end
end

RSpec.describe Wizard::SubscriberResearch::Step1, type: :model do
  subject { Wizard::SubscriberResearch::Step1.new({ min_floor: 2, max_price: 1000000 }, 
  {firstname: "Maxime", lastname: "Le Segretain", email: "mlesegret@gmail.com", phone: "0689716569"}) }
  it { is_expected.to validate_presence_of(:agglomeration_id) }
end

RSpec.describe Wizard::SubscriberResearch::Step2, type: :model do
  subject { Wizard::SubscriberResearch::Step2.new({ min_floor: 2, max_price: 1000000 }, 
  {firstname: "Maxime", lastname: "Le Segretain", email: "mlesegret@gmail.com", phone: "0689716569"}) }
  it { is_expected.to validate_presence_of(:min_surface) }
  it { is_expected.to validate_presence_of(:max_price) }
  it { is_expected.to validate_presence_of(:min_rooms_number) }
end

RSpec.describe Wizard::SubscriberResearch::Step3, type: :model do
  subject { Wizard::SubscriberResearch::Step3.new({ min_floor: 2, max_price: 1000000 }, 
  {firstname: "Maxime", lastname: "Le Segretain", email: "mlesegret@gmail.com", phone: "0689716569"}) }

  it { is_expected.to validate_presence_of(:subscriber_firstname) }
  it { is_expected.to validate_presence_of(:subscriber_lastname) }
  it { is_expected.to validate_presence_of(:subscriber_email) }
  it { is_expected.to validate_presence_of(:subscriber_phone) }
  it { should allow_value("0689716569").for(:subscriber_phone) }
  it { should_not allow_value("068971656").for(:subscriber_phone) }
end
