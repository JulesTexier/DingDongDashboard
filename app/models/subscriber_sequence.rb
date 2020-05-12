class SubscriberSequence < ApplicationRecord
  belongs_to :sequence
  belongs_to :subscriber
end
