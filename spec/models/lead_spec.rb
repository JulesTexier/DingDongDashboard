require 'rails_helper'

RSpec.describe Lead, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe Lead do
    describe "model" do
      it "has a valid factory" do
        expect(build(:lead)).to be_valid
      end
    end
  end
end
