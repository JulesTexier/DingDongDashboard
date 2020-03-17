require 'rails_helper'
require 'json'

RSpec.describe Subway, type: :model do

    before(:each) do 
        @subways = []
        obj = JSON.parse(File.read("./db/data/subways.json"))
        obj["stations"].each do |hsh|
            @subways.push(FactoryBot.create(:subway, name: hsh["metro"], line: hsh["ligne"]))
        end
    end

    it "is valid with valid attributes" do
        expect(@subways[0]).to be_a(Subway)
        expect(@subways[0]).to be_valid
        puts @subways[0].id
    end
  

end
