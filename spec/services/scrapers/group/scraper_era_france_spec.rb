require "rails_helper"

RSpec.describe Group::ScraperEraFrance, type: :service do
  ## TODO 01/06/2020 - We have a weird bug with Era - the request doesnt work locally but seems to work fine on heroku
  ## I've made a HF about the link just to see if on heroku, it does work or not...
  ## This error is logged in trello, TBC
  #   before(:all) do
  #     @s = Group::ScraperEraFrance.new
  #   end

  #   it "should launch and return proper number of properties" do
  #     VCR.use_cassette(@s.source) do
  #       expect(@s.launch).to be_a(Array)
  #       expect(Property.where(source: @s.source).count).to be >= 1
  #       expect(Property.where(source: @s.source).count).to be == @s.properties.count
  #     end
  #   end

  #   it "should return the right keys" do
  #     properties = @s.properties
  #     properties.each do |property|
  #       expect(property).to have_key(:has_elevator)
  #       expect(property).to have_key(:price)
  #       expect(property).to have_key(:rooms_number)
  #       expect(property).to have_key(:surface)
  #       expect(property).to have_key(:floor)
  #       expect(property).to have_key(:area)
  #       expect(property).to have_key(:description)
  #       expect(property).to have_key(:source)
  #     end
  #   end

  #   it "should return proper class for each keys" do
  #     properties = @s.properties
  #     properties.each do |property|
  #       expect(property[:has_elevator]).to be_in([true, false, nil])
  #       expect(property[:price]).to be_a(Integer)
  #       expect(property[:surface]).to be_a(Integer)
  #       expect(property[:floor]).to be_a(Integer).or be_a(NilClass)
  #       expect(property[:area]).to be_a(Area)
  #       expect(property[:description]).to be_a(String)
  #       expect(property[:source]).to be_truthy
  #     end
  #   end
end
