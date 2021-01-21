require 'csv'

class Migration
  #######################################################################
  # Script de migration de la liaison de l'objet agglo sur la recherche #
  #######################################################################

  def load_properties
    JSON.parse(File.read('dump_bdd_props_test.json')).each{|p| Property.create(p)}
  end

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

    Subscriber.where(id: subscriber_ids).each do |subscriber|

      #Remove saved_properties
      SavedProperty.where(research_id: subscriber.research.id).destroy_all unless subscriber.research.nil?

      #Remove research_areas
      ResearchArea.where(research_id: subscriber.research.id).destroy_all unless subscriber.research.nil?

      #Remove Subscriber Research
      subscriber.research.destroy unless subscriber.research.nil?
      
      #Remove Subscriber Sequences
      SubscriberSequence.where(subscriber: subscriber).destroy_all

      #Remove SubscriberNotes
      SubscriberNote.where(subscriber: subscriber).destroy_all
      
      #Remove Subscriber
      subscriber.destroy

      puts "Subscriber #{subscriber.id} has been removed, all attached objects also"
      
    end

  end

  def import_sl_contacts(agglo_name)
    contacts = CSV.parse(File.read("import/#{input_csv_name}.csv"), {:col_sep => ";"})
    agglomeration = Agglomeration.find_by(name: agglo_name)
    contacts.each do |contact|
      Subscriber.find_by(email: contact[])
    end
    byebug
  end

  def broker_repartition(agglomeration_id, since_date)
    broker_scope = Broker.where(agglomeration_id: agglomeration_id ).map{|b|[b.subscribers.count, b.id]}.sort_by{|i| i.first}.reverse.map{|e| e.last}
    subscriber_scope = Subscriber.where("created_at > ?", Time.parse(since_date) ).where(id: Broker.where(agglomeration_id: agglomeration_id ).map{|b| b.subscribers.map{|s| s.id}}.flatten).where(is_broker_affiliated: false).where.not(hot_lead: true)

    average = (subscriber_scope.count / broker_scope.count).to_f.to_i

    i = 0
    broker_scope.each do |b_id|
    b_subs = Broker.find(b_id).subscribers.where("created_at > ?", Time.parse(since_date) ).where(is_broker_affiliated: false, hot_lead:false)
      if b_subs.count > average 
        offset = b_subs.count - average 
        b_subs.last(offset).each{|s| s.update(broker_id: broker_scope[i+1] )}
      end
      i += 1
      break if i + 2 > broker_scope.count
    end
  end


end