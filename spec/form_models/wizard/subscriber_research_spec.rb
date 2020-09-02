require 'rails_helper'

RSpec.describe Wizard::SubscriberResearch::Base, type: :model do
  subject { Wizard::SubscriberResearch::Base.new({ min_floor: 2, max_price: 1000000 }) }

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
  subject { Wizard::SubscriberResearch::Step1.new({ min_floor: 2, max_price: 1000000 }) }

  it { is_expected.to validate_presence_of(:agglomeration) }
end

RSpec.describe Wizard::SubscriberResearch::Step2, type: :model do
  subject { Wizard::SubscriberResearch::Step2.new({ min_floor: 2, max_price: 1000000 }) }

  it { is_expected.to validate_presence_of(:min_surface) }
  it { is_expected.to validate_presence_of(:max_price) }
  it { is_expected.to validate_presence_of(:min_rooms_number) }
end

# RSpec.describe Wizard::User::Step2, type: :model do
#   subject { Wizard::User::Step2.new({ first_name: 'foo', last_name: 'bar' }) }

#   it { is_expected.to validate_presence_of(:email) }
#   it { is_expected.to allow_value('foo@bar.com').for(:email) }
#   it { is_expected.not_to allow_value('foobar.com').for(:email) }
#   it { is_expected.to validate_presence_of(:first_name) }
#   it { is_expected.to validate_presence_of(:last_name) }
# end

# RSpec.describe Wizard::User::Step3, type: :model do
#   subject { Wizard::User::Step3.new({ first_name: 'foo', last_name: 'bar' }) }

#   it { is_expected.to validate_presence_of(:email) }
#   it { is_expected.to allow_value('foo@bar.com').for(:email) }
#   it { is_expected.not_to allow_value('foobar.com').for(:email) }
#   it { is_expected.to validate_presence_of(:first_name) }
#   it { is_expected.to validate_presence_of(:last_name) }
#   it { is_expected.to validate_presence_of(:address_1) }
#   it { is_expected.to validate_presence_of(:zip_code) }
#   it { is_expected.to validate_presence_of(:country) }
# end

# RSpec.describe Wizard::User::Step4, type: :model do
#   subject { Wizard::User::Step4.new({ first_name: 'foo', last_name: 'bar' }) }

#   it { is_expected.to validate_presence_of(:email) }
#   it { is_expected.to allow_value('foo@bar.com').for(:email) }
#   it { is_expected.not_to allow_value('foobar.com').for(:email) }
#   it { is_expected.to validate_presence_of(:first_name) }
#   it { is_expected.to validate_presence_of(:last_name) }
#   it { is_expected.to validate_presence_of(:address_1) }
#   it { is_expected.to validate_presence_of(:zip_code) }
#   it { is_expected.to validate_presence_of(:country) }
#   it { is_expected.to validate_presence_of(:phone_number) }
# end