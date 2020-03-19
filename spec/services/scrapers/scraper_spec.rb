require "rails_helper"

RSpec.describe Scraper, type: :service do
  describe "PUBLIC_DATABASE_METHODS" do
    before(:each) do
      @s = Scraper.new
      @property = FactoryBot.create(:property)
      FactoryBot.create(:subway)

      @already_existing_property = {}
      @already_existing_property[:link] = "https://superimmo.com/annonces/achat-appartement-46m-paris-18eme-75018-xj51qh"
      @already_existing_property[:rooms_number] = 2
      @already_existing_property[:price] = 301000
      @already_existing_property[:area] = "75018"
      @already_existing_property[:surface] = 46

      @new_property = {}
      @new_property[:link] = "https://superimmo.com/annonces/achat-appartement-46m-paris-18eme-75018-xj51qh"
      @new_property[:rooms_number] = 3
      @new_property[:price] = 411000
      @new_property[:area] = "75015"
      @new_property[:surface] = 46

      @shit_property = {}
      @shit_property[:link] = "https://superimmo.com/annonces/achat-appartement-46m-paris-18eme-75018-xj51qh"
      @shit_property[:rooms_number] = 3
      @shit_property[:price] = 411000
      @shit_property[:area] = "75015"
      @shit_property[:surface] = 1600
    end

    context "is_already_exists + is_property_clean + is_dirty_property with 3 differents cases" do
      it "shoud be a true false methods" do
        expect(@s.is_already_exists(@already_existing_property)).to be_in([true, false])
        expect(@s.is_dirty_property(@already_existing_property)).to be_in([true, false])
        expect(@s.is_property_clean(@already_existing_property)).to be_in([true, false])
      end

      it "should return true for already_existing_property and false for new_property" do
        expect(@s.is_already_exists(@already_existing_property)).to eq(true)
        expect(@s.is_already_exists(@new_property)).to eq(false)
      end

      it "should return false for new and already existing prop, a true for shit property" do
        expect(@s.is_dirty_property(@already_existing_property)).to eq(false)
        expect(@s.is_dirty_property(@new_property)).to eq(false)
        expect(@s.is_dirty_property(@shit_property)).to eq(true)
      end

      it "should be true for new property, false for already existing and shit property" do
        expect(@s.is_property_clean(@already_existing_property)).to eq(false)
        expect(@s.is_property_clean(@shit_property)).to eq(false)
        expect(@s.is_property_clean(@new_property)).to eq(true)
      end
    end
  end

  describe "GENERIC METHODS" do
    before(:each) do
      @s = Scraper.new
    end
    context "testing simple gsub for many pages methods" do
      it "should be equal to something else" do
        expect(@s.page_nbr_to_url("salut-[[PAGE_NUMBER]]", 1)).to eq("salut-1")
        expect(@s.page_nbr_to_url("salut-[[PAGE_NUMBER]]", 129)).to eq("salut-129")
        expect(@s.page_nbr_to_url("salut-[[PAGE_NUMBER]]", "1")).to eq("salut-1")
        expect(@s.page_nbr_to_url("salut-[[PAGE_NUMBER]]", 123721)).to be_a(String)
        expect(@s.page_nbr_to_url("salut-[[PAGE_NUMBER]]", 123721)).not_to be_a(NilClass)
      end
    end
  end

  describe "XML ACCESSORS METHODS" do
    before(:each) do
      @s = Scraper.new
      @ssi = ScraperSuperImmo.new
      @html = @ssi.fetch_static_page(@ssi.url)
    end
    context "access_xml_text" do
      it "should return a string" do
        expect(@s.access_xml_text(@html, "body")).to be_a(String)
        expect(@s.access_xml_text(@html, "body")).not_to be_a(Array)
      end

      context "access_xml_raw" do
        it "should return an array" do
          expect(@s.access_xml_raw(@html, "body")).to be_a(Array)
          expect(@s.access_xml_raw(@html, "body")).not_to be_a(String)
        end
      end

      context "access_xml_link" do
        it "should return an array" do
          expect(@s.access_xml_link(@html, "p > a", "href")).to be_a(Array)
          expect(@s.access_xml_link(@html, "p > a", "href")[0].to_s).to be_a(String)
        end
      end

      context "access_xml_array_to_text" do
        it "should return an array" do
          expect(@s.access_xml_array_to_text(@html, "p > a")).to be_a(String)
          expect(@s.access_xml_array_to_text(@html, "p > a")).not_to be_a(Array)
        end
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

      it "should send us array with 1 if desc contains subway station" do
        FactoryBot.create(:subway)
        expect(@s.perform_subway_regex("Wagram")).to be_a(Array)
        expect(@s.perform_subway_regex("Wagram")).to eq([1])
        expect(@s.perform_subway_regex("Wagram")).to be_a(Array)
        expect(@s.perform_subway_regex("Wagram Wagram Wagram")).not_to eq([1, 1, 1])
        expect(@s.perform_subway_regex("Wagram Wagram Wagram")).to eq([1])
      end

      it "should send us empty array if no probent results if there is subway inside database" do
        FactoryBot.create(:subway)
        expect(@s.perform_subway_regex("Nothing")).to be_a(Array)
        expect(@s.perform_subway_regex("Nothing")).to eq([])
        expect(@s.perform_subway_regex("Nothing Nothing Nothing")).to eq([])
      end
    end
  end

  describe "FETCH METHODS" do
    before(:each) do
      @s = Scraper.new
      @si = ScraperSuperImmo.new
      @skmi = ScraperKmi.new
      @sbi = ScraperBienIci.new
    end

    it "should return a Nokogori element'" do
      expect(@s.fetch_static_page(@si.url)).to be_a(Nokogiri::HTML::Document)
    end

    it "should return an array of Nokogiri Elements" do
      expect(@s.fetch_many_pages(@skmi.url, 1, @skmi.main_page_cls)).to be_a(Array)
    end
  end
end
