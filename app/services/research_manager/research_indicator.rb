class ResearchManager::ResearchIndicator < ApplicationService

  def initialize(research_hash, areas_id, nb_days = 7)
    @research = Research.new(research_hash)
    @areas_id = areas_id
    @nb_days ||= 7
  end

  def call
   props = Property
      .where('created_at > ? ', Time.now - @nb_days.days)
      .where(area: @areas_id)
      .where('price <= ? AND surface >= ? AND rooms_number >= ?', @research.max_price, @research.min_surface, @research.min_rooms_number)
      .order(id: :desc)
      .limit(500)
    props.select{|prop| @research.matching_property?(prop, @areas_id)}.count
  end

end