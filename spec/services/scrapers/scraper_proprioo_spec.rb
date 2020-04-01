require "rails_helper"

RSpec.describe ScraperProprioo, type: :service do
  # before(:all) do
  #   @s = ScraperProprioo.new
  #   @limit = 3
  # end
  # context "This test runs a launcher and test point by point in a single test if it is properly returning correct datas" do
  #   it "should launch de scraper" do
  #     VCR.use_cassette("proprioo") do
  #       expect(@s.launch(@limit)).to be_a(Array)
  #       expect(@s.properties.count).to be == @limit
  #       expect(Property.where(source: @s.source).count).to be === @limit
  #       properties = @s.properties
  #       properties.each do |property|
  #         expect(property).to have_key(:has_elevator)
  #         expect(property).to have_key(:price)
  #         expect(property).to have_key(:rooms_number)
  #         expect(property).to have_key(:surface)
  #         expect(property).to have_key(:floor)
  #         expect(property).to have_key(:area)
  #         expect(property).to have_key(:description)
  #         expect(property).to have_key(:source)
  #         expect(property[:has_elevator]).to be_in([true, false, nil])
  #         expect(property[:price]).to be_a(Integer)
  #         expect(property[:surface]).to be_a(Integer)
  #         expect(property[:floor]).to be_a(Integer).or be_a(NilClass)
  #         expect(property[:area]).to be_a(String)
  #         expect(property[:description]).to be_a(String)
  #         expect(property[:source]).to be_truthy
  #       end
  #     end
  #   end
  # end
end
