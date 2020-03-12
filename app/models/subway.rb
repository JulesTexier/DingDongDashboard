class Subway < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }, allow_blank: false, allow_nil: false

  has_many :property_subways
  has_many :properties, through: :property_subways
end
