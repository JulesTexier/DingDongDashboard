require 'rails_helper'

RSpec.describe Property, type: :model do
#   pending "add some examples to (or delete) #{__FILE__}"
	before(:each) do 
		@property = FactoryBot.create(:property)
	end

	it "has a valid factory" do
		expect(build(:property)).to be_valid
	end
		
	context "validation" do

			it "is valid with valid attributes" do
				expect(@property).to be_a(Property)
			end
	
			describe "#price" do
				it { expect(@property).to validate_presence_of(:price) }
			end
	
			describe "#surface" do
			it { expect(@property).to validate_presence_of(:surface) }
			end
	
			describe "#rooms_number" do
			it { expect(@property).to validate_presence_of(:rooms_number) }
			end
	
		end

end
