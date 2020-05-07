class SequenceEmail < ApplicationRecord

  has_many :subscriber_sequence_emails
  has_many :subscribers, through: :subscriber_sequence_emails

end
