# require "rails_helper"

# RSpec.describe Scraper, type: :service do
#   before(:each) do
#     @s = Scraper.new
#     @xml = @s.fetch_static_page("https://www.superimmo.com/achat/ile-de-france/paris?sort=created_at")
#   end

#   context "scraper methods" do
#     it "should be nokogiri element" do
#       expect(@s.fetch_static_page("https://pawelurbanek.com/")).to be_a(Nokogiri::HTML::Document)
#     end
#   end

#   describe "little scraper methods" do
#     it "access xml text should call return a single string" do
#       expect(@s.access_xml_text(@xml, "section > div.media-body")).to be_a(String)
#     end

#     it "shouldn't be an array" do
#       expect(@s.access_xml_text(@xml, "section > div.media-body")).not_to be_a(Array)
#     end

#     it "shouldn't be an XML or Nokogori elemnt" do
#       expect(@s.access_xml_text(@xml, "section > div.media-body")).not_to be_a(Nokogiri::HTML::Document)
#       expect(@s.access_xml_text(@xml, "section > div.media-body")).not_to be_a(Nokogiri::XML::Document)
#     end
#   end
# end
