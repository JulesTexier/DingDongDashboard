class SavedProperty < ApplicationRecord
  belongs_to :research
  belongs_to :property

  validates :research, uniqueness: { scope: :property }
end
