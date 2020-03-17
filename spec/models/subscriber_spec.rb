require 'rails_helper'

RSpec.describe Subscriber, type: :model do

    describe Subscriber do 
      it "has a valid factory" do
        expect(build(:subscriber)).to be_valid
      end

      context "validations" do
        before { FactoryBot.build(:subscriber) }
        it do 
          should validate_uniqueness_of(:facebook_id).case_insensitive
          should validate_presence_of(:facebook_id)
          should validate_presence_of(:firstname)
          should validate_presence_of(:email)
          should validate_presence_of(:phone)
        end 
      end

      context "default values" do 
        it 'should define user as active by default' do 
          subscriber = FactoryBot.create(:subscriber)
          expect(subscriber.is_active).to eq(true)
          expect(subscriber.min_floor).to eq(0)
        end
      end

      context "associations" do
        before { FactoryBot.build(:subscriber) }
        it do 
          should have_many(:fav_properties).through(:favorites).class_name('Property')
          should have_many(:areas).through(:selected_areas).class_name('Area')
          should have_many(:districts).through(:selected_districts).class_name('District')
        end 
      end

    end

end