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
        selected_departments = []
        selected_departments.push("department " + department.id.to_s)
        selected_departments.push(department.name)
        department_areas = department.areas
        if department_areas.pluck(:id).all? { |e| research_area.include?(e) }
          research_area -= department_areas.pluck(:id)
          selected_departments.push("selected")
        end 
        areas.push(selected_departments)
        department_areas.pluck(:id, :name, :zip_code).each do |area|
          selected_areas = []
          selected_areas.push("area " + area[0].to_s)
          selected_areas.push(area[1])
          selected_areas.push(area[2])
          selected_areas.push("selected") if research_area.include?(area[0])
          areas.push(selected_areas)
        end
      end
      areas
    end
end
