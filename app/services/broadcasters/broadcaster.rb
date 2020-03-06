class Broadcaster

  attr_reader :manychat_client

  def initialize
      @manychat_client = Manychat.new
  end


  # Actual logic : Run every X minutes and process a batch of unprocessed new scrapped properties 
  def new_broadcast
      properties = self.get_unprocessed_properties
      properties.each do |prop|
          subscribers = prop.get_matching_subscribers
          subscribers.each do |sub|
              @manychat_client.send_single_property_card(sub, prop)
          end
          prop.has_been_processed = true 
          prop.save
      end
  end
  

  def good_morning
      subs = Subscriber.active
      subs.each do |sub|
          sub_mc_infos = @manychat_client.fetch_subscriber_mc_infos(sub)
          border = @manychat_client.is_last_interaction_borderline(sub_mc_infos[1]['data']) if sub_mc_infos[0] == true
          property_nbr = sub.get_morning_props.length
          if property_nbr > 0 && !border
              text = good_morning_text(property_nbr)
              webhook = ENV['BASE_URL'] + "api/v1/manychat/s/#{sub.id}/send/props/morning"
              btn_caption = '🚀 Recevoir !'
              @manychat_client.send_dynamic_button_message(sub, btn_caption, webhook, 'get', text, body = {})
          elsif border
              text = "🔔 Ton alerte est suspendue ! 🔔\u000A Nous avons arrêté ton alerte parce que nous avons remarqué que tu étais inactif 😊🙏\u000AClique sur le bouton pour continuer ta recherche !"
              webhook = ENV['BASE_URL'] + "api/v1/manychat/s/#{sub.id}/update"
              btn_caption = '🚀 Continuer !'
              body = {}
              body[:is_active] = true
              @manychat_client.send_dynamic_button_message(sub, btn_caption, webhook, 'post', text, body)
          else
              puts "No warning Good Morning Message for #{sub[:facebook_id]}."
          end
      end
  end

  private

  def get_unprocessed_properties
      return Property.where(has_been_processed: false)
  end

  def update_processed_properties(properties)
      properties.each do |p|
          p.has_been_processed = true
          p.save
      end
  end

  def update_processed_property(property)
      property.has_been_processed = true
      property.save
  end

  def good_morning_text(prop_nbr)
    if prop_nbr > 9
      text = "🔔 Ding Dong 🔔\u000APour bien commencer ta journée, 10 annonces sont tombées cette nuit. Clique ici pour les recevoir ! 👇"
    elsif prop_nbr > 1
      text = "🔔 Ding Dong 🔔\u000APour bien commencer ta journée, #{prop_nbr} annonces sont tombées cette nuit. Clique ici pour les recevoir ! 👇"
    else
      text = "🔔 Ding Dong 🔔\u000APour bien commencer ta journée, une annonce est tombée cette nuit. Clique ici pour la recevoir ! 👇"
    end
    return text
  end

end