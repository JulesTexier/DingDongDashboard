require "active_record/validations"
require "dotenv/load"
require "typhoeus"

# Manychat documentation
# https://manychat.github.io/dynamic_block_docs/

class Manychat
  attr_reader :token, :default_qr

  def initialize
    @token = "Bearer " + ENV["MANYCHAT_BOT_ID"].to_s + ":" + ENV["MANYCHAT_TOKEN"].to_s
    @default_qr = get_default_qr
  end

  # This method send a single property card to subscriber (i.e. : broadcaster use)
  def send_single_property_card(subscriber, property)
    return handle_manychat_response(send_content(subscriber, create_property_card(property, subscriber)))
  end

  # This methid is sending a gallery of property with an header or not according to template
  def send_properties_gallery(subscriber, properties, template = nil)
    return handle_manychat_response(send_content(subscriber, new_create_gallery_card(properties, subscriber, template)))
  end

  def send_no_props_msg(subscriber, template)
    return handle_manychat_response(send_content(subscriber, create_no_props_msg(subscriber, template)))
  end

  # This method is sending a gallery of all the images of a property + The text description (i.e. : internal chatbot Property Show use)
  def send_property_info_post_interaction(subscriber, property)
    first_call = handle_manychat_response(send_content(subscriber, create_gallery_images_property(property, subscriber)))
  end

  # This methd is sending a simple text message to subscriber 
  def send_text_message(subscriber, message)
    handle_manychat_response(send_content(subscriber,[create_message_text_hash(message)]))
  end

  # ------
  # FAVORITE MANAGEMENT
  # ------

  # This method send a gallery of a favorites properties of a subscriber
  def send_favorites_gallery_properties_card(subscriber)
    return handle_manychat_response(send_content(subscriber, create_favorites_gallery_card(subscriber)))
  end

  # This method send message after a property has been added to favorites
  def send_message_post_fav_added(subscriber, msg)
    if msg == "success"
      text = "L'annonce a été ajoutée à tes favoris !"
      response = handle_manychat_response(send_content(subscriber, [create_message_text_hash(text)]))
    elsif msg == "error_already_exists"
      text = "L'annonce est déjà dans tes favoris !"
      response = handle_manychat_response(send_content(subscriber, [create_message_text_hash(text)]))
    else
      text = "Oops, il semblerait qu'une erreur se soit produite, l'annonce n'a pas été ajoutée à tes favoris"
      response = handle_manychat_response(send_content(subscriber, [create_message_text_hash(text)]))
    end
    return response
  end

  # This method send message after a favory has been removed
  def send_message_post_fav_deleted(subscriber, msg)
    if msg == "success"
      text = "L'annonce a été supprimée de tes favoris !"
      response = handle_manychat_response(send_content(subscriber, [create_message_text_hash(text)]))
    else
      text = "Oops, il semblerait qu'une erreur se soit produite, l'annonce n'a pas été supprimée de des favoris"
      response = handle_manychat_response(send_content(subscriber, [create_message_text_hash(text)]))
    end
    return response
  end

  #This method send a basic message with a dynamic button to a subscriber
  def send_dynamic_button_message(subscriber, btn_caption, webhook, method, text, body)
    return handle_manychat_response(send_content(subscriber, create_dynamic_text_card(btn_caption, webhook, method, text, body)))
  end

  #This method fetch ManyChat infos from every subscriber who is is_active: true
  #Timer set every 10 requests so ManyChat doesn't block us with <TOO MANY REQUEST>
  def fetch_subscriber_mc_infos(subscriber)
    request = Typhoeus::Request.new(
      "https://api.manychat.com/fb/subscriber/getInfo?subscriber_id=#{subscriber.facebook_id}",
      method: :get,
      headers: { "Content-type" => "application/json", "Authorization" => self.token },
    )
    request.run
    return handle_manychat_response(request.response)
  end

  #This method evaluate if a subscriber is 72hours past its last interaction
  #If so, we update him to is_active: false
  def is_last_interaction_borderline(mc_subs_infos)
    response = false
    a = Time.parse(mc_subs_infos["last_interaction"]) + (72 * 60 * 60)
    b = Time.now
    if a < b
      sub = Subscriber.where(facebook_id: mc_subs_infos["id"])
      sub.update(is_active: false)
      response = true
    end
    return response
  end

  def reactivate_inactive_subscribers
    inactive_subscribers = Subscriber.inactive
    inactive_subscribers.each do |inactive_subscriber|
      mc_sub_infos = self.fetch_subscriber_mc_infos(inactive_subscriber)
      if mc_sub_infos[0] && inactive_subscriber.has_interacted(mc_sub_infos[1]["data"]["last_interaction"], 3) && mc_sub_infos[1]["data"]["status"] == "active"
        puts "\nSuccessful update for : #{inactive_subscriber.firstname} - ID: #{inactive_subscriber.id}\n\n"
        inactive_subscriber.update(is_active: true)
      end
    end
  end

  private

  ###################################
  # [DING DONG x MANYCHAT] COMPONENTS
  ###################################

  def create_no_props_msg(subscriber, template = nil)
    text = "😕 Oops, aucune annonce ne correspond ..."
    text = "Aucune annonce récente ne répond à tes critères de recherche 😕." if template == "last_properties"
    text = "Aucune annonce correspondant à tes critères n'est tombée cette nuit 😕." if template == "morning_properties"
    text += "\u000ANous t'invitions à modifier tes critères de recherche si tu souhaites recevoir plus d'annonces ⬇️"
    return [create_message_text_hash(text)]
  end

  def create_header_gallery_element_new_properties(number_of_properties)
    title = "🍾 "
    number_of_properties == 1 ? title += "#{number_of_properties} nouvelle annonce est tombée !" : title += "#{number_of_properties} nouvelles annonces sont tombées !"
    number_of_properties == 1 ? subtitle = "Fais défiler pour la découvrir ! ️↪️" : subtitle = "Fais défiler pour les découvrir ! ️↪️"
    image_url = "https://www.hellodingdong.com/content/gallery/rectangle/new_properties/#{number_of_properties}.png"
    # action_url = "https://hellodingdong.com/"
    create_header_gallery_element(title, subtitle, image_url)
  end

  def create_header_gallery_element_last_properties(number_of_properties)
    title = "🌟 "
    number_of_properties == 1 ? title += "Voici ta dernière annonce !" : title += "Voici tes #{number_of_properties} dernières annonces !"
    number_of_properties == 1 ? subtitle = "Fais défiler pour la découvrir ! ️↪️" : subtitle = "Fais défiler pour les découvrir ! ️↪️"
    image_url = "https://www.hellodingdong.com/content/gallery/rectangle/last_x_props/#{number_of_properties}.jpg"
    action_url = "https://hellodingdong.com/"
    create_header_gallery_element(title, subtitle, image_url)
  end

  def create_header_gallery_element_favorites
    title = "❤️ Favoris"
    subtitle = "Retrouve ici tous tes favoris! ️↪️"
    image_url = "https://www.hellodingdong.com/content/gallery/rectangle/favorites/favoris.jpg"
    action_url = "https://hellodingdong.com/"
    create_header_gallery_element(title, subtitle, image_url)
  end

  # This method prepare a message view for a property that can be included in a card or a gallery of cards
  def create_property_element(property, subscriber = nil, direct_source = false)
    buttons = []
    if subscriber.nil?
      buttons.push(create_url_button_hash("👀 Voir sur #{property.source}", property.link))
    else
      if direct_source
        buttons.push(create_url_button_hash("👀 Voir sur #{property.source}", property.link))
        webhook_fav = ENV["BASE_URL"] + "api/v1/favorites/"
        body_fav = { subscriber_id: subscriber.id, property_id: property.id }
        buttons.push(create_dynamic_button_hash("❤️ Ajouter favoris", webhook_fav, "POST", body_fav))
      else
        webhook = ENV["BASE_URL"] + "api/v1/manychat/s/#{subscriber.id}/send/props/#{property.id}/details"
        buttons.push(create_dynamic_button_hash("🙋 Voir plus", webhook, "GET"))
      end
    end
    return create_message_element_hash(property.get_title, property.manychat_show_description, property.get_cover, buttons)
  end

  # This method is building a single json_card for a property with the first image of the property
  def create_property_card(property, subscriber = nil)
    message_array = []
    elements = []
    elements.push(create_property_element(property, subscriber))
    message_array.push(create_message_card_hash("cards", elements, "square"))
    return message_array
  end

  # NEW - This method is building a json_gallery of cards for each property with the first image of each property
  def new_create_gallery_card(properties, subscriber = nil, template)
    properties.length > 9 ? properties = properties[0..9] : nil
    # no direct CTA (built-in show) by default
    direct_source = false
    elements = []
    if template == "last_properties"
      # adding headers
      elements.push(create_header_gallery_element_last_properties(properties.length))
      # direct CTA
      direct_source = true
    elsif template == "morning_properties"
      # direct CTA
      direct_source = true
    end

    # properties 
    properties.each do |property|
      elements.push(create_property_element(property, subscriber, direct_source))
    end

    message_array = []
    message_array.push(create_message_card_hash("cards", elements, "horizontal"))

    return message_array
  end

  # This method is bulding a json_gallery card of all images of a property
  def create_gallery_images_property(property, subscriber = nil)
    buttons = []
    buttons.push(create_url_button_hash("👀 Voir sur #{property.source}", property.link))
    if property.contact_number != nil && property.contact_number != "N/C"
      property.provider == "Particulier" ? caption = "☎️ Appeler le particulier" : caption = "Appeler l'agence"
      buttons.push(create_call_button_hash(caption, property.contact_number))
    end
    webhook_fav = ENV["BASE_URL"] + "api/v1/favorites/"
    body_fav = { subscriber_id: subscriber.id, property_id: property.id }
    buttons.push(create_dynamic_button_hash("❤️ Ajouter favoris", webhook_fav, "POST", body_fav))

    elements = []
    photo_counter = 1
    property.images.count <= 10 ? total_pic = property.images.count : total_pic = 10
    property.images.each do |img|
      elements.push(create_message_element_hash("📷 Photo #{photo_counter}/#{total_pic}", property.manychat_show_description_with_title, img, buttons))
      elements.length === 10 ? break : nil
      photo_counter += 1
    end
    puts elements
    message_array = []
    message_array.push(create_message_card_hash("cards", elements, "square"))

    return message_array
  end

  # This method is building a json_gallery of cards for each property in fav of a subscriber
  def create_favorites_gallery_card(subscriber)
    favs = subscriber.favorites
    message_array = []

    elements = []
    elements.push(create_header_gallery_element_favorites)
    if favs.length > 0
      favs.each do |fav|
        property = fav.property
        buttons = []
        # 1st btn : Source
        buttons.push(create_url_button_hash("👀 Voir sur #{property.source}", property.link))
        # 2nd btn : Remove from fav
        webhook_delete_fav = ENV["BASE_URL"] + "api/v1/favorites/#{fav.id}"
        buttons.push(create_dynamic_button_hash("💔 Retirer des favoris", webhook_delete_fav, "DELETE"))

        elements.push(create_message_element_hash(property.get_title, property.manychat_show_description, property.get_cover, buttons))
        elements.length == 10 ? break : nil
      end
      message_array.push(create_message_card_hash("cards", elements, "horizontal"))
    else
      text = "Oops, tu n'as aucune annonce en favoris ..."
      message_array.push(create_message_text_hash(text))
    end

    return message_array
  end

  # Getter method for default quick_replies menu
  def get_default_qr
    qr = [{
      "type": "flow",
      "caption": ":house: 5 annonces",
      "target": ENV["QR_ADS"],
    },
          {
      "type": "flow",
      "caption": "📞 Appeler mon conseiller",
      "target": "20200420082225_07451",
    },  {
      "type": "flow",
      "caption": "🧐 Préparer visite",
      "target": "20200406175824_347680",
    },{
      "type": "flow",
      "caption": "🤝 Négocier",
      "target": "20200417143528_857983",
    },
          {
      "type": "flow",
      "caption": "📝​ Faire une offre",
      "target": "20200420082225_057338",
    },
    {
      "type": "flow",
      "caption": ":no_entry: Stop",
      "target": ENV["QR_UNSUBS"],
    }]
    # [{
    #   "type": "flow",
    #   "caption": "🏠 5 annonces",
    #   "target": ENV["QR_ADS"],
    # },
    #       {
    #   "type": "flow",
    #   "caption": "📞 Appeler courtier",
    #   "target": "20200330083518_711940",
    # },
    #       {
    #   "type": "flow",
    #   "caption": "📝​🤝 Faire une offre",
    #   "target": "20200406085625_574803",
    # },
    #       {
    #   "type": "flow",
    #   "caption": "🧐 Préparer visite",
    #   "target": "20200406175824_347680",
    # },
    #       {
    #   "type": "flow",
    #   "caption": "⛔ Stop",
    #   "target": ENV["QR_UNSUBS"],
    # }]
    return qr
  end

  ##################################################################
  # STANDARD MANYCHAT COMPONENTS (Building unofficial ManyChat gem)
  ##################################################################

  #----------------
  # header for gallery
  #----------------
  def create_header_gallery_element(title, subtitle, image_url, buttons_array = [])
    title = title
    subtitle = subtitle
    image_url = image_url
    # action_url = action_url
    create_message_element_hash(title, subtitle, image_url, buttons_array)
  end

  #----------------
  # buttons
  #----------------
  def create_share_button_hash
    btn = {}
    btn[:type] = "share"
    return btn
  end

  def create_url_button_hash(caption, url)
    btn = {}
    btn[:type] = "url"
    btn[:caption] = caption
    btn[:url] = url
    # btn[:webview_size] = "full"
    return btn
  end

  def create_call_button_hash(caption, phone_number)
    btn = {}
    btn[:type] = "call"
    btn[:caption] = caption
    btn[:phone] = phone_number
    return btn
  end

  def create_dynamic_button_hash(caption, webhook, method, body = {})
    btn = {}
    btn[:type] = "dynamic_block_callback"
    btn[:caption] = caption
    btn[:url] = webhook
    btn[:method] = method
    header = {}
    header[:Authorization] = "Bearer " + ENV["BEARER_TOKEN"]
    btn[:headers] = header
    btn[:payload] = body
    return btn
  end

  #----------------
  # elements
  #----------------
  def create_message_element_hash(title, subtitle, image_url, buttons_array = [])
    element = {}
    element[:title] = title
    element[:subtitle] = subtitle
    element[:image_url] = image_url
    # element[:action_url] = action_url
    element[:buttons] = buttons_array
    return element
  end

  #----------------
  # messages
  #----------------
  def create_message_card_hash(type, elements_array, ratio)
    message = {}
    message[:type] = type
    message[:elements] = elements_array
    message[:image_aspect_ratio] = ratio
    return message
  end

  def create_message_text_hash(text)
    message = {}
    message[:type] = "text"
    message[:text] = text
    return message
  end

  #----------------
  # cards
  #----------------
  # This method is bulding a simple json card of a dynamic button with a caption
  def create_dynamic_text_card(btn_caption, webhook, method, text, body = {})
    buttons = []
    buttons.push(create_dynamic_button_hash(btn_caption, webhook, method, body))
    message_array = []
    message_hash = {}
    message_hash[:type] = "text"
    message_hash[:text] = text
    message_hash[:buttons] = buttons
    message_array.push(message_hash)
    return message_array
  end

  #----------------
  # actions
  #----------------
  def create_action_hash()
    action = {}
    return action
  end

  #----------------
  # quick_replies
  #----------------
  def create_quick_reply_hash(type, caption, target)
    qr = {}
    qr[:type] = type
    qr[:caption] = caption
    qr[:target] = target
    return qr
  end

  #----------------
  # final_json
  #----------------
  def create_final_json(subscriber, messages_array, actions_array = [], quick_replies_array = self.default_qr)
    {
      "subscriber_id": subscriber.facebook_id,
      "data": {
        "version": "v2",
        "content": {
          "messages": messages_array,
          "actions": actions_array,
          "quick_replies": quick_replies_array,
        },
      },
      "message_tag": "POST_PURCHASE_UPDATE",
    }
  end

  #----------------
  # sending HTTP Request
  #----------------
  # This method is sending to a subscriber the json_data via ManyChat API
  def send_content(subscriber, message_array)
    puts "*******"
    puts message_array
    json_data = create_final_json(subscriber, message_array).to_json

    request = Typhoeus::Request.new(
      "https://api.manychat.com/fb/sending/sendContent",
      method: :post,
      body: json_data,
      headers: { "Content-type" => "application/json", "Authorization" => self.token },
    )
    request.run
    response = request.response
    return response
  end

  def handle_manychat_response(response)
    status = response.options[:response_code].to_i
    body = JSON.parse(response.options[:response_body])

    if status == 200 || status == 204
      return [true, body]
    else
      return [false, body]
    end
  end
end
