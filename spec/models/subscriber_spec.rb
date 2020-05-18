require "rails_helper"

RSpec.describe Subscriber, type: :model do
  describe Subscriber do
    describe "model" do
      it "has a valid factory" do
        expect(build(:subscriber_dummy_fb_id)).to be_valid
      end

      context "validations" do
        before { FactoryBot.build(:subscriber) }
        it do
          should validate_presence_of(:firstname)
        end
      end

      context "default values" do
        it "should define user as active by default" do
          subscriber = FactoryBot.create(:subscriber_dummy_fb_id)
          expect(subscriber.is_active).to eq(false)
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
        @subscriber.areas << Area.new(name: "Paris 10ème")
      end

      describe "case subscriber matching properties values" do
        before :each do
          @property = FactoryBot.build(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
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
          @property = FactoryBot.build(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
        end

        context "Surface is not ok" do
          it "should NOT match user and property because of surface !" do
            @property.surface = @subscriber.min_surface - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Area is not ok" do
          it "should NOT match user and property because of area !" do
            @property.area = FactoryBot.create(:area, name: "Paris 1er")
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Rooms_number is not ok" do
          it "should NOT match user and property because of rooms_number !" do
            @property.rooms_number = @subscriber.min_rooms_number - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Price is not ok" do
          it "should NOT match user and property because of price !" do
            @property.price = @subscriber.max_price + 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        context "Floor is not ok" do
          it "should NOT match user and property because of floor !" do
            @property.floor = @subscriber.min_floor - 1
            expect(@subscriber.is_matching_property?(@property)).to eq(false)
          end
        end

        describe "elevator contraints" do
          describe "elevator is true but floor is inferior to min elevator_floor" do
            it "should match user and property (known elevator abscence but min_elevator_floor <)" do
              @property.has_elevator = false
              @property.floor = @subscriber.min_elevator_floor - 1
              expect(@subscriber.is_matching_property?(@property)).to eq(true)
            end
          end
          describe "floor is equal to min_elevator_floor but elevator is false" do
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

  describe "all #handle_form_filled use cases" do
    before :each do
      @sub = FactoryBot.create(:subscriber)
      @form_filled_status = FactoryBot.create(:status, name: "form_filled")
      @hunter_status = FactoryBot.create(:status, name: "real_estate_hunter")
      @has_not_messenger = FactoryBot.create(:status, name: "has_not_messenger")
      FactoryBot.create(:area)
      @subscriber_params = { "firstname" => "Maxime", "lastname" => "Le Segretain", "email" => "azekzae@gmail.com", "phone" => "0689716569", "additional_question" => "", "has_messenger" => "true", "project_type" => "1er achat", "max_price" => "400000", "min_surface" => "23", "min_rooms_number" => "1", "specific_criteria" => "", "initial_areas" => "1" }
    end
    context "testing if adequate status is create" do
      it "should return true because the update is working correctly" do
        expect(@sub.handle_form_filled(@subscriber_params)).to eq(true)
      end

      it "should check if subscriber has been updated" do
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.firstname).to eq("Maxime")
        expect(@sub.lastname).to eq("Le Segretain")
        expect(@sub.firstname).not_to eq("Jean")
        expect(@sub.lastname).not_to eq("Foutre")
      end

      it "should check if subscriber status form_filled has been created" do
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.statuses.last).to eq(@form_filled_status)
      end

      it "should check if subscriber status form_filled has been created, and has_not_messenger as will if user hasnt messenger" do
        @subscriber_params["has_messenger"] = "false"
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.statuses.first).to eq(@form_filled_status)
        expect(@sub.statuses.last).to eq(@has_not_messenger)
        expect(@sub.has_messenger).to eq(false)
      end

      it "should check if subscriber status form_filled and real_estate_hunter has been created" do
        @subscriber_params["project_type"] = "Chasseur"
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.statuses.first).to eq(@form_filled_status)
        expect(@sub.statuses.last).to eq(@hunter_status)
      end

      it "should only create form_filled status and launch onboarding broker method" do
        @sub = FactoryBot.create(:subscriber, broker: nil)
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.statuses.last).to eq(@form_filled_status)
        expect(@sub.statuses.last).to eq(@form_filled_status)
        expect(@sub.broker).to eq(Broker.get_current_broker)
      end
    end
  end
end
