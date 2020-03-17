require "rails_helper"

RSpec.describe ScraperSuperImmo, type: :service do
  before(:all) do
    s = ScraperSuperImmo.new.extract_first_page
  end
end
