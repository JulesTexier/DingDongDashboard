require "rails_helper"

RSpec.describe Subscriber, type: :model do
  # let (:property) { FactoryBot.create(:property) }

  describe Subscriber do
    describe "model" do
      it "has a valid factory" do
        expect(build(:subscriber_dummy_fb_id)).to be_valid
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
        it "should define user as active by default" do
          subscriber = FactoryBot.create(:subscriber_dummy_fb_id)
          expect(subscriber.is_active).to eq(true)
          expect(subscriber.min_floor).to eq(0)
        end
      end

      context "associations" do
        before { FactoryBot.build(:subscriber) }
        it do
          should have_many(:fav_properties).through(:favorites).class_name("Property")
          should have_many(:areas).through(:selected_areas).class_name("Area")
          should have_many(:districts).through(:selected_districts).class_name("District")
        end
      end
    end

    describe "is_matching_property?" do
      before :each do
        @subscriber = FactoryBot.build(:subscriber, max_price: 500000, min_surface: 20, min_rooms_number: 1, min_floor: 2, min_elevator_floor: 4)
        @subscriber.areas << Area.new(name: "75010")
      end

      describe "case subscriber matching properties values" do
        before :each do
          @property = FactoryBot.build(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first.name, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
        end

        context "floor and elevator are unknown" do
          it "should match user and property !" do
            expect(@subscriber.is_matching_property?(@property)).to eq(true)
          end
        end

        context "floor is known (and ok) and elevator is not false" do
          before :each do
            @property.floor = @subscriber.min_floor
          end

          it "should match user and property (known floor)" do
            expect(@subscriber.is_matching_property?(@property)).to eq(true)
          end

          it "should match user and property (known floor)" do
            @property.has_elevator = true
            expect(@subscriber.is_matching_property?(@property)).to eq(true)
          end

          it "should match when user wants 75016 and property is 75116" do 
            @subscriber.areas << Area.new(name: "75016")
            @property.area = "75116"
            expect(@subscriber.is_matching_property?(@property)).to eq(true)
          end
        end

        context "floor is equal to min_elevator_floor and elevator is true" do
          it "should match user and property (known floor)" do
            @property.floor = @subscriber.min_elevator_floor
            @property.has_elevator = true
            expect(@subscriber.is_matching_property?(@property)).to eq(true)
          end
        end
      end

      describe "Property NOT matchs" do
        before :each do
          @property = FactoryBot.build(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first.name, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
        end

        context "Surface is not ok" do
          it "should NOT match user and property because of surface !" do
            @property.surface = @subscriber.min_surface - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Area is not ok" do
          it "should NOT match user and property because of area !" do
            @property.area = "75001"
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Rooms_number is not ok" do
          it "should NOT match user and property because of rooms_number !" do
            @property.area = @subscriber.min_rooms_number - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Price is not ok" do
          it "should NOT match user and property because of price !" do
            @property.price = @subscriber.max_price + 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context 'Floor is not ok' do 
          it "should NOT match user and property because of floor !" do
            @property.floor = @subscriber.min_floor - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        describe 'elevator contraints' do 
          describe 'elevator is true but floor is inferior to min elevator_floor' do 
            it "should match user and property (known elevator abscence but min_elevator_floor <)" do
              @property.has_elevator = false
              @property.floor = @subscriber.min_elevator_floor - 1
              expect(@subscriber.is_matching_property?(@property)).to eq(true)
            end
          end
          describe 'floor is equal to min_elevator_floor but elevator is false' do 
            it "should NOT match user and property (known elevator absence)" do
              @property.has_elevator = false
              @property.floor = @subscriber.min_elevator_floor
              expect(@subscriber.is_matching_property?(@property)).to eq(false)
            end
          end
        end
      end
    end
  end
end
