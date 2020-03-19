require 'rails_helper'

RSpec.describe Subscriber, type: :model do

    before(:each) do 
      @subscriber = FactoryBot.create(:subscriber)
    end

    context "validation" do

      it "is valid with valid attributes" do
        expect(@subscriber).to be_a(Subscriber)
        expect(@subscriber).to be_valid
      end
  
      describe "#facebook_id" do
        it "should not be valid without facebook_id" do
          bad_user = FactoryBot.build(:subscriber, facebook_id: nil)
          expect(bad_user).not_to be_valid
          # test très sympa qui permet de vérifier que la fameuse formule user.errors retourne bien un hash qui contient une erreur concernant le first_name. 
          expect(bad_user.errors.include?(:facebook_id)).to eq(true)
        end
      end

    end

end