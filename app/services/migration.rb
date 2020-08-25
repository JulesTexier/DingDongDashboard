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
    end
  end

  ### 2 ) Boucle sur tous les hunters

  def hunter_migration_to_research
    HunterSearch.all.each do |hs|
    # Migration des critères vers un objet Research
      if hs.hunter.researches.empty?
        puts "Hunter #{hs.hunter.id} prepared to migrate."
        research = Research.new(hunter: hs.hunter)
        research.min_floor = hs.min_floor
        research.has_elevator = hs.has_elevator
        research.min_elevator_floor = hs.min_elevator_floor
        research.min_surface = hs.min_surface
        research.min_rooms_number = hs.min_rooms_number
        research.max_price = hs.max_price
        research.min_price = hs.min_price
        research.max_sqm_price = hs.max_sqm_price
        research.is_active = hs.is_active
        research.balcony = hs.balcony
        research.terrace = hs.terrace
        research.garden = hs.garden
        research.new_construction = hs.new_construction
        research.last_floor = hs.last_floor
        research.home_type = hs.home_type
        research.apartment_type = hs.apartment_type
        research.created_at = hs.created_at
        
        research.save
        puts "Research #{research.id} saved."
      # Migration des selected_areas vers des research_area
        hs.hunter_search_areas.each do |hsa|
          ResearchArea.create(research: research, area: hsa.area)
        end
      
      # Migration des favoris vers des saved_properties
        hs.selections.each do |fav|
          SavedProperty.create(research: research, property: fav.property)
        end
        puts "Hunter #{hs.hunter.id} successfully migrated."
      end
    end 
  end
end