class Area < ApplicationRecord
    has_many :selected_areas
    has_many :properties
    has_many :subscribers, through: :selected_areas
    
    has_many :hunter_search_areas
    has_many :hunter_searchs, through: :hunter_search_areas

    def self.get_active
        Area.where(zone: ["Paris", "Première Couronne"])
    end

    def self.get_aggregate_data_for_selection(areas_id)
			master_areas = []
			zone_areas = Area.all.pluck(:zone).uniq!
			zone_areas.each do |zone| 
				zone_hash = {}
				zone_hash[:zone] = zone
				zone_hash[:areas] = Area.where(zone: zone).pluck(:id, :name)
				master_areas.push(zone_hash)
			end

			master_areas.each do |zone|
				zone[:areas].each do |area|
					selected = areas_id.include?(area[0]) ? "selected" : ""
					area.push(selected)
				end
			end
			return master_areas
    end

end
