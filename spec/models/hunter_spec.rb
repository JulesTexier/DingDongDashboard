require 'rails_helper'

RSpec.describe Hunter, type: :model do
  describe Subscriber do
    describe "model" do
      it "has a valid factory" do
        expect(build(:hunter)).to be_valid
      end
    end
  end
end
