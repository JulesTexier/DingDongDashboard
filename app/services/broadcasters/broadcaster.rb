class Broadcaster
  attr_reader :manychat_client

  def initialize
    @manychat_client = Manychat.new
  end

  ###########################
  ## BROADCASTER RAKETASKS ##
  ###########################

  def live_broadcast
    properties = Property.unprocessed
    update_processed_properties(properties)
    live_messenger_broadcaster(properties)
    live_email_broadcaster(properties)
  end

  def live_messenger_broadcaster(properties)
    researches = Research.active_subs_research_messenger
    researches.each do |research|
      matched_props = []
      properties.each do |prop|
        matched_props.push(prop) if research.matching_property?(prop.attributes, research.areas.ids)
      end
      ##TODO - refacto this chunk of code
      if matched_props.length > 0
        if matched_props.length < 9
          @manychat_client.send_properties_gallery(research.subscriber, matched_props)
        elsif matched_props.length >= 9 && matched_props.length < 19
          @manychat_client.send_properties_gallery(research.subscriber, matched_props[0..8])
          @manychat_client.send_properties_gallery(research.subscriber, matched_props[9..18])
        elsif matched_props.length >= 19 && matched_props.length < 29
          @manychat_client.send_properties_gallery(research.subscriber, matched_props[0..8])
          @manychat_client.send_properties_gallery(research.subscriber, matched_props[9..18])
          @manychat_client.send_properties_gallery(research.subscriber, matched_props[19..28])
        end
      end
      puts "#{matched_props.length} properties sent to Subscriber #{research.subscriber.firstname} + #{research.subscriber.lastname}"
    end
  end

  def live_email_broadcaster(properties)
    researches = Research.active_subs_research_email
    researches.each do |research|
      research_props = []
      research_area = research.areas.ids
      properties.each do |prop|
        research_props.push(prop) if research.matching_property?(prop.attributes, research_area)
      end
      SubscriberMailer.property_mailer(research.subscriber, research_props).deliver_now if !research_props.empty?
    end
  end

  def good_morning
    ##TODO - make this method for mailers as well, currently only for messenger
    sub_researches = Research.active_subs_research_messenger
    sub_researches.each do |sub_research|
      sub_mc_infos = @manychat_client.fetch_subscriber_mc_infos(sub_research.subscriber)
      border = @manychat_client.is_last_interaction_borderline(sub_mc_infos[1]["data"]) if sub_mc_infos[0] == true
      property_nbr = sub_research.morning_properties.length
      if property_nbr > 0 && !border
        text = good_morning_text(property_nbr)
        webhook = ENV["BASE_URL"] + "api/v1/manychat/s/#{sub_research.subscriber.id}/send/props/morning"
        btn_caption = "🚀 Recevoir !"
        @manychat_client.send_dynamic_button_message(sub_research.subscriber, btn_caption, webhook, "get", text, body = {})
      elsif border
        text = "🔔 Votre alerte est en pause ! 🔔\u000A Nous stoppons les messages automatiques au bout d'une semaine sans action de votre part 😊🙏\u000AContinuez à recevoir les annonces simplement en cliquant ici"
        webhook = ENV["BASE_URL"] + "api/v1/manychat/s/#{sub_research.subscriber.id}/update"
        btn_caption = "🚀 Continuer !"
        body = {}
        body[:is_active] = true
        body[:message] = "reactivation"
        @manychat_client.send_dynamic_button_message(sub_research.subscriber, btn_caption, webhook, "post", text, body)
        # SubscriberNote.create(subscriber: sub_research.subscriber, content: "Alerte désactivée, utilisateur inactif depuis 6 jours")
      else
        puts "No warning Good Morning Message for #{sub_research.subscriber[:facebook_id]}."
      end
    end
  end

  def good_morning_mailer
     researches = Research.active_subs_research_email
     researches.each do |sub_research|
      research_props = []
      research_area = research.areas.ids
      properties.each do |prop|
        research_props.push(prop) if research.matching_property?(prop.attributes, research_area)
      end
      SubscriberMailer.property_mailer(research.subscriber, research_props).deliver_now unless research_props.empty?
     end
  end


  private

  def update_processed_properties(properties)
    properties.each do |p|
      prop = Property.find(p["id"])
      prop.has_been_processed = true
      prop.save
    end
  end

  def good_morning_text(prop_nbr)
    if prop_nbr > 9
      text = "🔔 Ding Dong 🔔\u000APour bien commencer votre journée, 10 annonces sont tombées cette nuit. Cliquez ici pour les recevoir ! 👇"
    elsif prop_nbr > 1
      text = "🔔 Ding Dong 🔔\u000APour bien commencer votre journée, #{prop_nbr} annonces sont tombées cette nuit. Cliquez ici pour les recevoir ! 👇"
    else
      text = "🔔 Ding Dong 🔔\u000APour bien commencer votre journée, une annonce est tombée cette nuit. Cliquez ici pour la recevoir ! 👇"
    end
    return text
  end
end
