class ResearchManager::ResearchProperties < ApplicationService

  def initialize(research_id, nb_days = 7)
    @research = Research.find(research_id)
    @nb_days = nb_days
  end

  def call
   props = Property
      .where('created_at > ? ', Time.now - @nb_days.days)
      .where(area: @research.areas.pluck(:id))
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', @research.max_price, @research.min_surface, @research.min_rooms_number)
      .order(id: :desc)
      .limit(500)
    props.select{|prop| @research.matching_property?(prop, @research.areas.pluck(:id))}
  end

end