class SelectedDistrict < ApplicationRecord
    belongs_to :subscriber
    belongs_to :district
end
