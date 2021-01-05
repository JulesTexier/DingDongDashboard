class ResearchIndicator
  ATTRS = %w(id rooms_number surface price floor area_id has_elevator has_terrace has_garden has_balcony is_new_construction is_last_floor images link flat_type)

  def get_estimation(research_hash, areas_id, nb_days = 7)
   research = Research.new(research_hash)
   props = Property
      .where('created_at > ? ', Time.now - nb_days.days)
      .where(area: areas_id)
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', research.max_price, research.min_surface, research.min_rooms_number)
      .order(id: :desc)
      .limit(500)
    props.select{|prop| research.matching_property?(prop, areas_id)}.count
  end

end