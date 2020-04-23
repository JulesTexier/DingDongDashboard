class Area < ApplicationRecord
    has_many :selected_areas
    has_many :properties
    has_many :subscribers, through: :selected_areas
end
