class Migration
  ###################################################################
  # Script de migration de la rentrée (v4) - Ete 2020 (first part)
  ###################################################################

  ### 1) Boucle sur tous les Subscribers 

  def subscriber_migration_to_research
    Subscriber.all.each do |subscriber|
      # Migration des critères vers un objet Research
      if subscriber.research.nil?
        puts "Subscriber #{subscriber.id} prepared to migrate."
        research = Research.new(subscriber: subscriber)
        research.min_floor = subscriber.min_floor
        research.has_elevator = subscriber.min_elevator_floor.nil? ? false : true
        research.min_elevator_floor = subscriber.min_elevator_floor
        research.min_surface = subscriber.min_surface
        research.min_rooms_number = subscriber.min_rooms_number
        research.max_price = subscriber.max_price
        research.min_price = subscriber.min_price
        research.max_sqm_price = subscriber.max_sqm_price
        research.is_active = subscriber.is_active
        research.balcony = subscriber.balcony
        research.terrace = subscriber.terrace
        research.garden = subscriber.garden
        research.new_construction = subscriber.new_construction
        research.last_floor = subscriber.last_floor
        research.home_type = subscriber.home_type
        research.apartment_type = subscriber.apartment_type
        research.created_at = subscriber.created_at
        research.agglomeration = "Paris" ##because all our users are in Paris, which is convenient AF

        research.save
        puts "Research #{research.id} saved."
        # Migration des selected_areas vers des research_area
        subscriber.selected_areas.each do |sa|
          ResearchArea.create(research: research, area: sa.area)
        end
      
        # Migration des favoris vers des saved_properties
        subscriber.favorites.each do |fav|
          SavedProperty.create(research: research, property: fav.property)
        end
        puts "Subscriber #{subscriber.id} successfully migrated."
      end
      subscriber.update(notary: Notary.first) if subscriber.notary.nil? 
      subscriber.update(contractor: Contractor.first) if subscriber.contractor.nil? 
      subscriber.update(broker: Broker.find_by(email: "etienne@hellodingdong.com")) if subscriber.broker.nil? 
      subscriber.update(messenger_flux: true, email_flux: false) if subscriber.messenger_flux.nil?
    end
  end

  def agglomeration_migration
    agglo_file = YAML.load_file("db/data/agglomeration.yml")
    agglo_file.each do |agglo_data|
      agglo = Agglomeration.find_by(name: agglo_data["agglomeration"])
      if agglo.blank?
        a = Agglomeration.new
        a.name = agglo_data["agglomeration"]
        a.image_url = agglo_data["image_url"]
        a.is_active = agglo_data["is_active"]
        a.save
        agglo_data["zone"].each do |department|
          Department.create(name: department, agglomeration: a) unless Department.where(name: department).any?
        end
      else
        agglo_data["zone"].each do |department|
          Department.create(name: department, agglomeration: agglo) unless Department.where(name: department).any?
        end
      end

      areas = Area.all 
      areas.each do |area|
        if area.department.nil?
          area.department = Department.find_by(name: area.zone)
          area.save
          puts area.department.name
        end
      end
    end
  end
end