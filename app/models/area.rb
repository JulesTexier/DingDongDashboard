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
				zone_hash[:areas] = Area.where(zone: zone).pluck(:id, :name, :zip_code)
				master_areas.push(zone_hash)
			end

			master_areas.each do |zone|
				zone[:areas].each do |area|
					selected = areas_id.include?(area[0]) ? "selected" : ""
					area.push(selected)
				end
			end
      return master_areas
      # areas = Area.where(zone: zones).pluck(:id, :name, :zip_code)
      # areas.each do |area|
      #   selected = areas_id.include?(area[0]) ? "selected" : ""
      #   area.push(selected)
      # end
      # areas
    end

    def self.get_agglo_infos
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
    end

    def self.get_active_agglo_infos
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
      agglo_infos.reject {|agglo| !agglo["is_active"]}
    end

    def self.get_zones_from_agglo(agglo)
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
    end

    def self.get_selected_agglo_area(selected_agglo, areas_id)
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
      zones = []
      agglo_infos.each do |agglo|
        if agglo["agglomeration"] == selected_agglo
          zones.push(agglo["zone"])
        end
      end
      areas = Area.where(zone: zones).pluck(:id, :name, :zip_code)
      areas.each do |area|
        selected = areas_id.include?(area[0]) ? "selected" : ""
        area.push(selected)
      end
      areas
    end

    def self.global_zones(selected_agglo)
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
      global_zones = []
      agglo_infos.each do |agglo| 
        if agglo["agglomeration"] == selected_agglo 
          agglo["zone"].each do |zone_name|
            zone_area = ["GlobalZone", zone_name]
            global_zones.push(zone_area)
          end
        end
      end
      global_zones
    end
end
