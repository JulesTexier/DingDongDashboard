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

    context "Property matching"
      subscriber =  FactoryBot.build(:subscriber, max_price: 500000, min_surface: 20, min_rooms_number: 1, min_floor: 2, min_elevator_floor: 4)
      subscriber.areas << Area.new(name: "75010")
      property = FactoryBot.build(:property, price: subscriber.max_price, surface: subscriber.min_surface, area: subscriber.areas.first.name, rooms_number: subscriber.min_rooms_number, floor: nil, has_elevator: nil )

      it 'should match user and property !' do
        expect(subscriber.is_matching_property?(property)).to eq(true)
      end

      it 'should NOT match user and property because of surface !' do
        property.surface = subscriber.min_surface - 1
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end
      it 'should NOT match user and property because of area !' do
        property.area = "75001"
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end
      it 'should NOT match user and property because of rooms_number !' do
        property.area = subscriber.min_rooms_number - 1
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end
      it 'should NOT match user and property because of price !' do
        property.price = subscriber.max_price + 1
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end

      # Floor constraints
      it 'should match user and property (known floor)' do
        property = FactoryBot.build(:property, price: subscriber.max_price, surface: subscriber.min_surface, area: subscriber.areas.first.name, rooms_number: subscriber.min_rooms_number, floor: subscriber.min_floor, has_elevator: true )
        expect(subscriber.is_matching_property?(property)).to eq(true)
      end
      it 'should NOT match user and property because of floor !' do
        property.floor = subscriber.min_floor - 1
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end

      # Elevator constraints
      it 'should match user and property (known elevator presence)' do
        property = FactoryBot.build(:property, price: subscriber.max_price, surface: subscriber.min_surface, area: subscriber.areas.first.name, rooms_number: subscriber.min_rooms_number, floor: subscriber.min_elevator_floor, has_elevator: true )
        expect(subscriber.is_matching_property?(property)).to eq(true)
      end
      it 'should match user and property (known elevator abscence but min_elevator_floor <)' do
        property.has_elevator = false
        property.floor = subscriber.min_elevator_floor - 1
        expect(subscriber.is_matching_property?(property)).to eq(true)
      end
      it 'should NOT match user and property (known elevator absence)' do
        property.has_elevator = false
        property.floor = subscriber.min_elevator_floor
        expect(subscriber.is_matching_property?(property)).to eq(false)
      end

      
    end

end