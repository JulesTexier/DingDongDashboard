class Contractor < ApplicationRecord
  has_many :subscribers
  has_one_attached :avatar
end
