class Selection < ApplicationRecord
  belongs_to :hunter_search, foreign_key: :hunter_search_id, class_name: "HunterSearch"
  belongs_to :property, foreign_key: :property_id, class_name: "Property"

  validates :hunter_search, uniqueness: { scope: :property }
end
