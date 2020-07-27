class Hunter < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :researches
  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :company, presence: true
end
