class Area < ApplicationRecord
    has_many :selected_areas
    has_many :subscribers, through: :selected_areas

    has_many :research_areas
    has_many :researches, through: :research_areas

    has_many :properties
    
    has_many :hunter_search_areas
    has_many :hunter_searchs, through: :hunter_search_areas

    belongs_to :department

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

    def self.get_areas_for_hunters(areas_id)
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

    def self.get_agglo_infos
      collection = []
      i = 0
      raw_area = YAML.load_file("./db/data/agglomeration.yml")
      raw_area.each do |area|
        collection.push([area["agglomeration"], area["is_active"], area["image_url"]])
        i += 1
      end
      collection
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

    def self.selected_area_onboarding(agglomeration, area_params)
      all_selected_areas = []
      departments = Agglomeration.find_by(name: agglomeration).departments
      departments.each do |department|
        a = []
        a.push("department " + department.id.to_s)
        a.push(department.name)
        a.push("selected") if area_params.include?("department " + department.id.to_s)
        all_selected_areas.push(a)
        department.areas.pluck(:id, :name, :zip_code).each do |area|
          b = []
          b.push("area " + area[0].to_s)
          b.push(area[1])
          b.push(area[2])
          b.push("selected") if area_params.include?("area " + area[0].to_s)
          all_selected_areas.push(b)
        end
      end
      all_selected_areas
    end

    def self.selected_area_edit(agglomeration, research_area = nil)
      departments = Agglomeration.find_by(name: agglomeration).departments
      areas = []
      departments.each do |department|
        a = []
        a.push("department " + department.id.to_s)
        a.push(department.name)
        if department.areas.pluck(:id).all? { |e| research_area.include?(e) }
          research_area -= department.areas.pluck(:id)
          a.push("selected")
        end 
        areas.push(a)
        department.areas.pluck(:id, :name, :zip_code).each do |area|
          b = []
          b.push("area " + area[0].to_s)
          b.push(area[1])
          b.push(area[2])
          b.push("selected") if research_area.include?(area[0])
          areas.push(b)
        end
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
