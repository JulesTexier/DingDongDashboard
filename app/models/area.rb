class Area < ApplicationRecord
    has_many :selected_areas
    has_many :subscribers, through: :selected_areas
    has_many :properties
    
    has_many :hunter_search_areas
    has_many :hunter_searchs, through: :hunter_search_areas

    def self.get_active
        Area.where(zone: ["Paris", "Première Couronne"])
    end

    def self.get_aggregate_data_for_selection(areas_id)
      areas = []
      areas_id.each do |area|
        area.push(Area.find(area).pluck(:name, :zip_code))
        area.push("selected")
      end
      return areas
    end


    def self.get_agglo_infos
      YAML.load_file("./db/data/agglomeration.yml")
    end

    def self.get_active_agglo_infos
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
      agglo_infos.reject {|agglo| !agglo["is_active"]}
    end

    def self.get_agglo_from_zone(zone_name)
      agglo_infos = YAML.load_file("./db/data/agglomeration.yml")
      agglo_from_zone = []
      agglo_infos.each do |agglo| 
        agglo["zone"].any? do |zone| 
          if zone.include?(zone_name)
            agglo_from_zone.push(agglo["agglomeration"])
          end
        end
      end
      agglo_from_zone
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
