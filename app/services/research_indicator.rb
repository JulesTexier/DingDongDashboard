class ResearchIndicator

  def get_estimation(research_hash, areas, nb_days = 7)
   research = Research.new(research_hash)
   research.areas << Area.where(id: areas)
   research.average_results_estimation(nb_days)
  end

end