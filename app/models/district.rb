class District < ApplicationRecord
    has_many :selected_districts
    has_many :subscribers, through: :selected_districts

    has_many :property_districts
    has_many :properties, through: :property_districts
end
