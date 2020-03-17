require 'rails_helper'

RSpec.describe Property, type: :model do

    before(:each) do 
      @property = FactoryBot.create(:property)
    end

    context "validation" do

      it "is valid with valid attributes" do
        expect(@property).to be_a(Property)
        expect(@property).to be_valid
      end
  
    #   describe "#source" do
    #     it "should not be valid without source" do
    #       bad_property = FactoryBot.build(:property, source: nil)
    #       expect(bad_property).not_to be_valid
          
    #       # test très sympa qui permet de vérifier que la fameuse formule user.errors retourne bien un hash qui contient une erreur concernant le first_name. 
    #       expect(bad_user.errors.include?(:property)).to eq(true)
    #     end
    #   end

    end

end