require "rails_helper"

RSpec.describe Scraper, type: :service do
  describe "PUBLIC_DATABASE_METHODS" do
    before(:each) do
      @s = Scraper.new
      @good_hashed_property = {}
      @good_hashed_property[:link] = "https://superimmo.com/annonces/achat-appartement-46m-paris-18eme-75018-xj51qh"
      @good_hashed_property[:provider] = "Agence"
      @good_hashed_property[:has_been_processed] = false
      @good_hashed_property[:flat_type] = "Appartement"
      @good_hashed_property[:rooms_number] = 2
      @good_hashed_property[:price] = 501000
      @good_hashed_property[:source] = "SuperImmo"
      @good_hashed_property[:area] = "75018"
      @good_hashed_property[:surface] = 46
      @good_hashed_property[:description] = "Super appartement ma couille"
      @good_hashed_property[:floor] = nil
      @good_hashed_property[:has_elevator] = nil

      @p = Property.last
    end

    context "is_already_exists(hashed_property)" do
      it "should always return a boolean" do
        expect(@s.is_already_exists(@good_hashed_property)).to be_in([true, false])
      end

      it "should return true" do
        expect(@s.is_already_exists(@p)).to eq(true)
      end
    end
  end

  describe "REGEX_METHODS" do
    before(:each) do
      @s = Scraper.new
    end
    context "perform_floor_regex(str)" do
      it "shoud send us nilClass if there is no match with floor str" do
        expect(@s.perform_floor_regex("Salut les copains")).to be_a(NilClass)
      end

      it "shoud not be a string" do
        expect(@s.perform_floor_regex("Salut les copains")).not_to be_a(String)
      end

      it "shoud be equal to specific integer and not return string" do
        expect(@s.perform_floor_regex("Premier étage")).to eq(1)
        expect(@s.perform_floor_regex("1er étage")).to eq(1)
        expect(@s.perform_floor_regex("Deuxieme étage")).to eq(2)
        expect(@s.perform_floor_regex("2eme étage")).to eq(2)
        expect(@s.perform_floor_regex("5eme et dernier étage")).to eq(5)
        expect(@s.perform_floor_regex("2eme et dernier étage")).to eq(2)
        expect(@s.perform_floor_regex("Deuxieme étage")).not_to eq("2")
      end
    end

    context "perform_elevator_regex(str)" do
      it "shoud send us true if string is 'avec ascenseur' in any capitalize format" do
        expect(@s.perform_elevator_regex("avec ascenseur")).to eq(true)
        expect(@s.perform_elevator_regex("Avec Ascenseur")).to eq(true)
        expect(@s.perform_elevator_regex("Avec AscenseUr")).to eq(true)
      end

      it "shoud send us false if string is 'sans ascenseur' in any capitalize format" do
        expect(@s.perform_elevator_regex("sans ascenseur")).to eq(false)
        expect(@s.perform_elevator_regex("Sans Ascenseur")).to eq(false)
        expect(@s.perform_elevator_regex("SanS AscenseUr")).to eq(false)
      end

      it "shoud send us nil if string is 'sans ascenseur' in any capitalize format" do
        expect(@s.perform_elevator_regex("Salut les copains")).to eq(nil)
        expect(@s.perform_elevator_regex("Salut les copains")).to be_a(NilClass)
      end
    end

    context "perform_subway_regex(str)" do
      it "shoud send us empty array if no probent results" do
        expect(@s.perform_subway_regex("Nothing")).to be_a(Array)
        expect(@s.perform_subway_regex("Nothing")).to eq([])
      end
    end
  end
end
