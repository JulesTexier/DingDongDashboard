class BrokerShift < ApplicationRecord
  has_many :permanences
  has_many :brokers, through: :permanences
end
