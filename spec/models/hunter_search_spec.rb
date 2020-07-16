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
          attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)
          @property = Property.where(id: prop.id).pluck(*attrs).map { |p| attrs.zip(p).to_h }
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
            @property.first["has_elevator"] = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end

        context "floor is equal to min_elevator_floor and elevator is true" do
          it "should match user and property (known floor)" do
            @property.first["floor"] = @hunter_search.min_elevator_floor
            @property.first["has_elevator"] = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end
      end

      describe "Property NOT matchs" do
        before :each do
          prop = FactoryBot.create(:property, price: @hunter_search.min_price, surface: @hunter_search.min_surface, area: @hunter_search.areas.first, rooms_number: @hunter_search.min_rooms_number, floor: nil, has_elevator: nil)
          attrs = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link)
          @property = Property.where(id: prop.id).pluck(*attrs).map { |p| attrs.zip(p).to_h }
        end

        context "Surface is not ok" do
          it "should NOT match user and property because of surface !" do
            @property.first["surface"] = @hunter_search.min_surface - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Area is not ok" do
          it "should NOT match user and property because of area !" do
            @property.first["area_id"] = Area.find_by(name: "Paris 1er").id
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Rooms_number is not ok" do
          it "should NOT match user and property because of rooms_number !" do
            @property.first["rooms_number"] = @hunter_search.min_rooms_number - 1
            expect(@hunter_search.is_matching_property?(@property.first, @hunter_search.areas.ids)).to eq(false)
          end
        end

        context "Price is too low" do
          it "should NOT match user and property because of price !" do
            @property.first["price"] = @hunter_search.min_price - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Price is too high" do
          it "should NOT match user and property because of price !" do
            @property.first["price"] = @hunter_search.max_price + 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "SQM Price is too high" do
          it "should NOT match user and property because of price !" do
            @property.first["price"] = 1000000
            @property.first["surface"] = 80
            @property.each do |prop|
              expect(@hunter_search.is_matching_max_sqm_price(prop["price"],prop["surface"])).to eq(false)
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Floor is not ok" do
          it "should NOT match user and property because of floor !" do
            @property.first["floor"] = @hunter_search.min_floor - 1
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
        end

        context "Exterior is not ok" do
          # Exterior single 
          it "should NOT match user and property because of garden !" do
            @property.first["has_garden"] = false
            @hunter_search.garden = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
          it "should NOT match user and property because of garden !" do
            @property.first["has_balcony"] = false
            @hunter_search.balcony = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
          it "should NOT match user and property because of garden !" do
            @property.first["has_terrace"] = false
            @hunter_search.terrace = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
          # Exterior multi
          it "should NOT match user and property because of terrace !" do
            @property.first["has_balcony"] = true
            @property.first["has_garden"] = true
            @hunter_search.terrace = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(false)
            end
          end
          it "should match user and property because of garden !" do
            @property.first["has_balcony"] = false
            @property.first["has_garden"] = true
            @hunter_search.garden = true
            @hunter_search.balcony = true
            @property.each do |prop|
              expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
            end
          end
        end

        describe "elevator contraints" do
          describe "elevator is false but floor is inferior to min elevator_floor" do
            it "should match user and property (known elevator abscence but min_elevator_floor <)" do
              @property.first["has_elevator"] = false
              @property.first["floor"] = @hunter_search.min_elevator_floor - 1
              @property.each do |prop|
                expect(@hunter_search.is_matching_property?(prop, @hunter_search.areas.ids)).to eq(true)
              end
            end
          end
          describe "floor is equal to min_elevator_floor but elevator is false" do
            it "should NOT match user and property (known elevator absence)" do
              @property.first["has_elevator"] = false
              @property.first["surface"] = @hunter_search.min_elevator_floor
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
