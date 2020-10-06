class Agglomeration < ApplicationRecord
  has_many :departments
  has_many :brokers
  has_many :researches
end
