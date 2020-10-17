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

  def has_stopped_migration
    subscriber_ids_scope = SubscriberNote.all.map{|sn| sn.subscriber.id}.uniq
    Subscriber.where(id: subscriber_ids_scope).each do |subscriber|
      last_note = subscriber.subscriber_notes.last
      stop_test = !last_note.content.empty? && last_note.content == "L'utilisateur a arrêté son alerte." ? true : false
      subscriber.update(has_stopped: true, has_stopped_at: last_note.created_at) if stop_test
    end
  end

  def remove_subscriber(subscriber_ids)
    subscriber_ids.each do |sub_id|

      sub = Subscriber.find(sub_id)
      unless sub.nil?
        # Get infos 
        research = sub.research
        
        #Remove saved_properties
        SavedProperty.where(research_id: research.id).destroy_all

        #Remove research_areas
        ResearchArea.where(research_id: research.id).destroy_all

        #Remove Subscriber Research
        research.destroy

        #Remove SubscriberNotes
        SubscriberNote.where(subscriber_id: sub_id).destroy_all
        
        #Remove Subscriber
        sub.destroy

        puts "Subscriber #{sub_id} has been removed, all attached objects also"

      end
    end
  end


end