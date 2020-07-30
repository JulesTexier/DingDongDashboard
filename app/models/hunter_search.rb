class HunterSearch < ApplicationRecord
  belongs_to :hunter
  has_many :hunter_search_areas
  has_many :areas, through: :hunter_search_areas

  has_many :selections
  has_many :properties, through: :selections, source: :property
end
