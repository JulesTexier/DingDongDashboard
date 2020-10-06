class SubscriberSequence < ApplicationRecord
  belongs_to :sequence
  belongs_to :subscriber
  belongs_to :agglomeration, optional: true
end
