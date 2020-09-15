class Department < ApplicationRecord
  belongs_to :agglomeration
  has_many :areas
end
