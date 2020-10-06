class Migration
  #######################################################################
  # Script de migration de la liaison de l'objet agglo sur la recherche #
  #######################################################################

  def agglomeration_migration
    subs = Subscriber.includes(:research).where(researches: { agglomeration_id: nil} )
  end
end