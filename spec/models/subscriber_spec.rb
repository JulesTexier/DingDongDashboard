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
        @subscriber = FactoryBot.create(:subscriber, max_price: 500000, min_surface: 20, min_rooms_number: 1, min_floor: 2, min_elevator_floor: 4)
        @subscriber.areas << Area.new(name: "Paris 10ème")
      end

      describe "case subscriber matching properties values" do
        before :each do
          prop = FactoryBot.create(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
          @property = Property.where(id: prop.id).pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)
        end

        context "floor and elevator are unknown" do
          it "should match user and property !" do
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(true)
            end
          end
        end

        context "floor is known (and ok) and elevator is not false" do
          before :each do
            @property.first[4] = @subscriber.min_floor
          end

          it "should match user and property (known floor)" do
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(true)
            end
          end

          it "should match user and property (known floor)" do
            @property.first[6] = true
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(true)
            end
          end
        end

        context "floor is equal to min_elevator_floor and elevator is true" do
          it "should match user and property (known floor)" do
            @property.first[4] = @subscriber.min_elevator_floor
            @property.first[6] = true
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(true)
            end
          end
        end
      end

      describe "Property NOT matchs" do
        before :each do
          prop = FactoryBot.create(:property, price: @subscriber.max_price, surface: @subscriber.min_surface, area: @subscriber.areas.first, rooms_number: @subscriber.min_rooms_number, floor: nil, has_elevator: nil)
          @property = Property.where(id: prop.id).pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)
        end

        context "Surface is not ok" do
          it "should NOT match user and property because of surface !" do
            @property.first[2] = @subscriber.min_surface - 1
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
            end
          end
        end

        context "Area is not ok" do
          it "should NOT match user and property because of area !" do
            @property.first[5] = Area.find_by(name: "Paris 1er").id
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
            end
          end
        end

        context "Rooms_number is not ok" do
          it "should NOT match user and property because of rooms_number !" do
            @property.first[1] = @subscriber.min_rooms_number - 1
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
            end
          end
        end

        context "Price is not ok" do
          it "should NOT match user and property because of price !" do
            @property.first[3] = @subscriber.max_price + 1
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
            end
          end
        end

        context "Floor is not ok" do
          it "should NOT match user and property because of floor !" do
            @property.first[4] = @subscriber.min_floor - 1
            @property.each do |prop|
              expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
            end
          end
        end

        describe "elevator contraints" do
          describe "elevator is true but floor is inferior to min elevator_floor" do
            it "should match user and property (known elevator abscence but min_elevator_floor <)" do
              @property.first[6] = false
              @property.first[4] = @subscriber.min_elevator_floor - 1
              @property.each do |prop|
                expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(true)
              end
            end
          end
          describe "floor is equal to min_elevator_floor but elevator is false" do
            it "should NOT match user and property (known elevator absence)" do
              @property.first[6] = false
              @property.first[4] = @subscriber.min_elevator_floor
              @property.each do |prop|
                expect(@subscriber.is_matching_property?(prop, @subscriber.areas.ids)).to eq(false)
              end
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
      @subscriber_params = { "firstname" => "Maxime", "lastname" => "Le Segretain", "email" => "azekzae@gmail.com", "phone" => "0689716569", "additional_question" => "", "has_messenger" => "true", "project_type" => "1er achat", "max_price" => "400000", "min_surface" => "23", "min_rooms_number" => "1", "specific_criteria" => "", "initial_areas" => "1" }
      # # // Broker creation 
      # @aurelien = FactoryBot.create(:subscriber_aurelien)
      # @melanie = FactoryBot.create(:subscriber_melanie)
      # @hugo = FactoryBot.create(:subscriber_hugo)
      # @amelie = FactoryBot.create(:subscriber_amelie)
      # @veronique = FactoryBot.create(:subscriber_veronique)
      # @greg = FactoryBot.create(:broker_greg)
      @broker_shift = FactoryBot.create(:broker_shift, day: Time.now.wday, starting_hour: Time.now.hour - 1, ending_hour: Time.now.hour + 1, shift_type: "regular")
      @broker = FactoryBot.create(:broker)
      @broker.shifts << @broker_shift

      @broker_shift_2= FactoryBot.create(:broker_shift, day: Time.now.wday, starting_hour: Time.now.hour - 1, ending_hour: Time.now.hour + 1, shift_type: "subscription")
      @broker_2 = FactoryBot.create(:broker)
      @broker_2.shifts << @broker_shift_2
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

      it "should only create form_filled status and attribute regular broker" do
        @sub = FactoryBot.create(:subscriber, broker: nil)
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.statuses.last).to eq(@form_filled_status)
        expect(@sub.statuses.last).to eq(@form_filled_status)
        expect(@sub.broker).to eq(Broker.get_current)
        expect(@sub.broker).not_to eq(Broker.get_current("subscription"))
      end

      it "should only create form_filled status and attribute subscription test broker if subscriber comes from adequate sequence ..." do
        @sub = FactoryBot.create(:subscriber, broker: nil)
        @subscriber_sequence = SubscriberSequence.create(subscriber: @sub, sequence: FactoryBot.create(:sequence_subscriber_bm))
        @sub.handle_form_filled(@subscriber_params)
        expect(@sub.broker).to eq(Broker.get_current("subscription"))
        expect(@sub.broker).not_to eq(Broker.get_current)
      end
    end
  end
end
