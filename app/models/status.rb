class Status < ApplicationRecord
  has_many :subscriber_statuses
  has_many :subscribers, through: :subscriber_statuses
end
