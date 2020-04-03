require "rails_helper"

RSpec.describe Scraper, type: :service do
  describe "PUBLIC_DATABASE_METHODS UPDATED" do
    context "Testing is_prop_fake?(prop) to see if there is pb with the property without checking DB" do
      before(:all) do
        @s = Scraper.new
      end
      it "should return true if price is 0 and surface nil" do
        expect(@s.is_prop_fake?({ price: 0, surface: nil })).to eq(true)
      end
      it "should return true if each attributes is equal to 0 and random integer respectively" do
        expect(@s.is_prop_fake?({ price: 0, surface: 20 })).to eq(true)
        expect(@s.is_prop_fake?({ price: 20, surface: 0 })).to eq(true)
        expect(@s.is_prop_fake?({ price: 0, surface: 0 })).to eq(true)
      end
      it "should return true if each attributes is string and not integer" do
        expect(@s.is_prop_fake?({ price: "0", surface: "20" })).to eq(true)
        expect(@s.is_prop_fake?({ price: "20", surface: "0" })).to eq(true)
        expect(@s.is_prop_fake?({ price: "0", surface: "0" })).to eq(true)
      end
      it "should return true if price is nil and surface nil" do
        expect(@s.is_prop_fake?({ price: nil, surface: nil })).to eq(true)
      end
      it "should return true if we try to divide with or by 0" do
        expect(@s.is_prop_fake?({ price: 3000000, surface: 0 })).to eq(true)
        expect(@s.is_prop_fake?({ price: 0, surface: 230 })).to eq(true)
      end
      it "should return true if the €/m2 is under 5000" do
        expect(@s.is_prop_fake?({ price: 20000, surface: 20 })).to eq(true)
        expect(@s.is_prop_fake?({ price: 2000000, surface: 2000 })).to eq(true)
      end
      it "should return false if the €/m2 is over 5000, so the test pass" do
        expect(@s.is_prop_fake?({ price: 400000, surface: 20 })).to eq(false)
      end
    end

    context "Testing is_link_in_db?(prop) to see if the property already exists in DB by its link" do
      before(:all) do
        @s = Scraper.new
        FactoryBot.create(:property, link: "https://google.com")
      end

      it "should return true because it already exists" do
        expect(@s.is_link_in_db?({ :link => "https://google.com" })).to eq(true)
        expect(@s.is_link_in_db?({ :link => "https://google.com    " })).to eq(true)
        expect(@s.is_link_in_db?({ :link => "            https://google.com    " })).to eq(true)
      end

      it "should return false because the link is different" do
        expect(@s.is_link_in_db?({ :link => "https://google.com/lmao" })).to eq(false)
        expect(@s.is_link_in_db?({ :link => "https://lmfao.com" })).to eq(false)
        expect(@s.is_link_in_db?({ :link => "htps://lmfao.com" })).to eq(false)
      end
    end

    context "Testing does_prop_exists?(prop) to see if the property already exists in DB by its link" do
      before(:each) do
        @s = Scraper.new
        FactoryBot.create(:property, created_at: 6.days.ago, area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com")
        @prop = { area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com" }
      end

      it "should return true because the two properties are the same" do
        expect(@s.does_prop_exists?(@prop.except(:area), 7)).to eq(true)
        expect(@s.does_prop_exists?(@prop.except(:rooms_number), 7)).to eq(true)
        expect(@s.does_prop_exists?(@prop.except(:surface), 7)).to eq(true)
        expect(@s.does_prop_exists?(@prop.except(:price), 7)).to eq(true)
      end

      it "should return false because the two properties are the same, but the timeframe is outside the property created_at" do
        expect(@s.does_prop_exists?(@prop, 3)).to eq(false)
        expect(@s.does_prop_exists?(@prop, 4)).to eq(false)
        expect(@s.does_prop_exists?(@prop, 6)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:area), 3)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:area), 4)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:area), 6)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:rooms_number), 3)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:rooms_number), 4)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:rooms_number), 6)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:price), 3)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:price), 4)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:price), 6)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:surface), 3)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:surface), 4)).to eq(false)
        expect(@s.does_prop_exists?(@prop.except(:surface), 6)).to eq(false)
      end
    end

    context "Testing go_to_prop?(prop, time)" do
      before(:each) do
        @s = Scraper.new
        FactoryBot.create(:property, created_at: 6.days.ago, area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com")
      end

      it "should return false because @prop is the same as a property inside DB" do
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
      end

      it "should return false because price or surface is nil or equal to 0" do
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: nil, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: nil, price: 400000, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: 0, price: 400000, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 0, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: nil, price: 400000, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: "23", price: "0", rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: nil, price: "400000", rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
      end

      it "should return false because link is the same has a property inside DB" do
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com" }, 7)).to eq(false)
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "     https://google.com    " }, 7)).to eq(false)
      end

      it "should return true because the property isnt the same, and the timeframe is out of reach of property inside DB and link is different but arguments are the same" do
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com/different_link" }, 5)).to eq(true)
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com/different_link" }, 4)).to eq(true)
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 400000, rooms_number: 1, link: "https://google.com/different_link" }, 3)).to eq(true)
      end

      it "should return true because price is different and therefore link is different and out of timeframe" do
        expect(@s.go_to_prop?({ area: "75018", surface: 23, price: 390000, rooms_number: 1, link: "https://google.com/new_link/" }, 7)).to eq(true)
      end
    end

    context "Testing desc_comparator" do
      before(:each) do
        @s = Scraper.new
        @old_property = FactoryBot.create(:property, created_at: Time.now - 25.days, price: 600000, surface: 60)
        @c = { description: "À 50 mètres du M°Jules Joffrin et de la mairie, dans immeuble pierre de taille        , chaleureux 2 pièces de 37,20 m² comprenant entrée, séjour, cuisine séparée, chambre, WC séparés, salle de bains, cave. Parquets, moulures, cheminée. 1er étage vue sur l’église. À rafraichir. EXCLUSIVITÉ ACOPA." }
        @d = { description: "À 50 mètres du M°Jules Joffrin et de la mairie, dans immeuble pierre de taille        , chaleureux 2 pièces de 37,20 m² comprenant entrée, séjour, cuisine séparée, chambre, WC séparés, salle de bains, cave. Parquets." }
        @e = { description: "A 51 yards de Jules Joffrin, je suis un agent qui casse les couilles, j'adore l'immobilier" }
      end

      it "is the same property but is in of our validator range but can't be inserted because of description similarities" do
        expect(@s.desc_comparator(@d[:description], @old_property.description)).to eq(true)
      end

      it "is a different property but with the sames attributes, therefor can be inserted" do
        expect(@s.desc_comparator(@e[:description], @old_property.description)).to eq(false)
      end

      it "should return true because the descriptions are the same" do
        expect(@s.desc_comparator(@c[:description], @d[:description])).to eq(true)
      end

      it "should return false because the descriptions arnt the same" do
        expect(@s.desc_comparator(@d[:description], @e[:description])).to eq(false)
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
      @ssi = RegularSites::ScraperSuperImmo.new
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
      @si = RegularSites::ScraperSuperImmo.new
      @skmi = SmallSites::ScraperKmi.new
      @sbi = RegularSites::ScraperBienIci.new
    end

    it "should return a Nokogori element'" do
      expect(@s.fetch_static_page(@si.url)).to be_a(Nokogiri::HTML::Document)
    end

    it "should return an array of Nokogiri Elements" do
      expect(@s.fetch_many_pages(@skmi.url, 1, @skmi.main_page_cls)).to be_a(Array)
    end
  end
end
