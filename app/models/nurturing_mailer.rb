class NurturingMailer < ApplicationRecord
  validates :time_frame, presence: true
  validates :template, presence: true
end
