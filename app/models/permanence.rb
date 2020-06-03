class Permanence < ApplicationRecord
  belongs_to :broker_shift
  belongs_to :broker
end
