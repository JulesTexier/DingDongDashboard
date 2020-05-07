class SubscriberSequenceEmail < ApplicationRecord
  belongs_to :sequence_email
  belongs_to :subscriber
end
