class Migration
  #######################################################################
  # Script de migration de la liaison de l'objet agglo sur la recherche #
  #######################################################################

  def agglomeration_migration
    researches = Research.where(agglomeration_id: nil)
    researches.each do |research|
      agglomeration = research.areas.first.department.agglomeration unless research.areas.empty?
      unless agglomeration.nil?
        research.update(agglomeration_id: agglomeration.id)
        puts "Research #{research.id.to_s} updated"
      end
    end
  end
end