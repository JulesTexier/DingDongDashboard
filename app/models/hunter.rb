class Hunter < ApplicationRecord
  has_many :hunter_searches
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :company, presence: true
end
