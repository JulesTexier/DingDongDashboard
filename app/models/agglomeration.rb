class Agglomeration < ApplicationRecord
  has_many :departments
  has_many :brokers
  has_many :researches
  has_many :subscriber_sequences
end
