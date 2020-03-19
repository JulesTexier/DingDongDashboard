require "rails_helper"

RSpec.describe ScraperLogicImmo, type: :service do
  before(:all) do
    @s = ScraperLogicImmo.new
    @limit = 3
    @s.launch(@limit)
  end

  it "should return an number of scraped properties" do
    expect(@s.properties.count).to be == @limit
  end

  it "should return an array of hashes" do
    expect(@s.properties.first).to have_key(:has_elevator)
    expect(@s.properties.first).to have_key(:price)
    expect(@s.properties.first).to have_key(:rooms_number)
    expect(@s.properties.first).to have_key(:surface)
    expect(@s.properties.first).to have_key(:floor)
    expect(@s.properties.first).to have_key(:area)
    expect(@s.properties.first).to have_key(:description)
    expect(@s.properties.first).to have_key(:source)
  end

  it "should return an hash with specific type of data" do
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
