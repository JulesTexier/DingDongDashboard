class NurturingMailer < ApplicationRecord
  default :from => "annonces@hellodingdong.com"
  validates :time_frame, presence: true
  validates :template, presence: true
end
