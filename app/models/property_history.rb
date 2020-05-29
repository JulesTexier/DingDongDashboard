class PropertyHistory < ApplicationRecord
  validates :link, presence: true, format: URI::regexp(%w[http https])
end
