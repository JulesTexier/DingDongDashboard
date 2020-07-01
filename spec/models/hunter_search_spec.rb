require 'rails_helper'

RSpec.describe HunterSearch, type: :model do
  describe Subscriber do
    describe "model" do
      it "has a valid factory" do
        expect(build(:hunter_search)).to be_valid
      end
    end

    describe "is_matching_property?" do
      before :each do
        @hunter_search = FactoryBot.create(:hunter_search, min_price: 300000, max_price: 1000000, min_surface: 40, min_rooms_number: 1, min_floor: 2, min_elevator_floor: 4, max_sqm_price: 10000)
        @hunter_search.areas << Area.new(name: "Paris 10ème")
     end

      describe "case hunter_search MATCH properties values" do
        before :each do
          prop = FactoryBot.create(:property, price: @hunter_search.min_price, surface: @hunter_search.min_surface, area: @hunter_search.areas.first, rooms_number: @hunter_search.min_rooms_number, floor: nil, has_elevator: nil)
          @property = Property.where(id: prop.id).pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)
        end

        context "floor and elevator are unknown" do
          it "should match user and property !" do
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end

        context "floor is known (and ok) and elevator is not false" do
          before :each do
            @property.first[4] = @hunter_search.min_floor
          end

          it "should match user and property (known floor)" do
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end

          it "should match user and property (known floor)" do
            @property.first[6] = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end

        context "floor is equal to min_elevator_floor and elevator is true" do
          it "should match user and property (known floor)" do
            @property.first[4] = @hunter_search.min_elevator_floor
            @property.first[6] = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end
      end

      describe "Property NOT matchs" do
        before :each do
          prop = FactoryBot.create(:property, price: @hunter_search.min_price, surface: @hunter_search.min_surface, area: @hunter_search.areas.first, rooms_number: @hunter_search.min_rooms_number, floor: nil, has_elevator: nil)
          @property = Property.where(id: prop.id).pluck(:id, :rooms_number, :surface, :price, :floor, :area_id, :has_elevator)
        end

        context "Surface is not ok" do
          it "should NOT match user and property because of surface !" do
            @property.first[2] = @hunter_search.min_surface - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Area is not ok" do
          it "should NOT match user and property because of area !" do
            @property.first[5] = Area.find_by(name: "Paris 1er").id
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Rooms_number is not ok" do
          it "should NOT match user and property because of rooms_number !" do
            @property.first[1] = @hunter_search.min_rooms_number - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Price is too low" do
          it "should NOT match user and property because of price !" do
            @property.first[3] = @hunter_search.min_price - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Price is too high" do
          it "should NOT match user and property because of price !" do
            @property.first[3] = @hunter_search.max_price + 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "SQM Price is too high" do
          it "should NOT match user and property because of price !" do
            @property.first[3] = 1000000
            @property.first[2] = 80
            @property.each do |prop|
              expect(@hunter_search.is_matching_max_sqm_price(prop[3],prop[2])).to eq(false)
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Floor is not ok" do
          it "should NOT match user and property because of floor !" do
            @property.first[4] = @hunter_search.min_floor - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        describe "elevator contraints" do
          describe "elevator is false but floor is inferior to min elevator_floor" do
            it "should match user and property (known elevator abscence but min_elevator_floor <)" do
              @property.first[6] = false
              @property.first[4] = @hunter_search.min_elevator_floor - 1
              @property.each do |prop|
                expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
              end
            end
          end
          describe "floor is equal to min_elevator_floor but elevator is false" do
            it "should NOT match user and property (known elevator absence)" do
              @property.first[6] = false
              @property.first[4] = @hunter_search.min_elevator_floor
              @property.each do |prop|
                expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
              end
            end
          end
        end
      end
    end

  end
end
