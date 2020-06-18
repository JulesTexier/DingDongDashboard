class Area < ApplicationRecord
    has_many :selected_areas
    has_many :properties
    has_many :subscribers, through: :selected_areas
    
    has_many :hunter_search_areas
    has_many :hunter_searchs, through: :hunter_search_areas

end
