class SubscriberStatus < ApplicationRecord
  belongs_to :status
  belongs_to :subscriber
end
