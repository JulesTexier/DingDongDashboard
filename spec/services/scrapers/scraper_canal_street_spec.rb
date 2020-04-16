require "rails_helper"

RSpec.describe Independant::ScraperCanalStreet, type: :service do
  before(:all) do
    @s = Independant::ScraperCanalStreet.new
  end

  it "should launch and return proper number of properties" do
    VCR.use_cassette(@s.source) do
      expect(@s.launch).to be_a(Array)
      expect(Property.where(source: @s.source).count).to be >= 1
      expect(Property.where(source: @s.source).count).to be == @s.properties.count
    end
  end

  it "should return the right keys" do
    properties = @s.properties
    properties.each do |property|
      expect(property).to have_key(:has_elevator)
      expect(property).to have_key(:price)
      expect(property).to have_key(:rooms_number)
      expect(property).to have_key(:surface)
      expect(property).to have_key(:floor)
      expect(property).to have_key(:area)
      expect(property).to have_key(:description)
      expect(property).to have_key(:source)
    end
  end

  it "should return proper class for each keys" do
    properties = @s.properties
    properties.each do |property|
      expect(property[:has_elevator]).to be_in([true, false, nil])
      expect(property[:price]).to be_a(Integer)
      expect(property[:surface]).to be_a(Integer)
      expect(property[:floor]).to be_a(Integer).or be_a(NilClass)
      expect(property[:area]).to be_a(String)
      expect(property[:description]).to be_a(String)
      expect(property[:source]).to be_truthy
    end
  end
end
