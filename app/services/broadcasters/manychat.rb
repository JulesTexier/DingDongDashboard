require 'active_record/validations'
require 'dotenv/load'
require 'typhoeus'


# Manychat documentation
# https://manychat.github.io/dynamic_block_docs/

class Manychat

    attr_reader :token, :default_qr

    def initialize
        @token = 'Bearer ' + ENV['MANYCHAT_BOT_ID'].to_s + ":" + ENV['MANYCHAT_TOKEN'].to_s
        @default_qr = get_default_qr
    end

    # This method send a single property card to subscriber (i.e. : broadcaster use) 
    def send_single_property_card(subscriber, property)
        return handle_manychat_response(send_content(subscriber, create_property_card(property, subscriber)))
    end

    # This method send a gallery of a bunch of properties card to subscriber (i.e. : latest properties, morning properties ....) 
    def send_gallery_properties_card(subscriber, properties)
        return handle_manychat_response(send_content(subscriber, create_gallery_card(properties, subscriber)))
    end

    # This method is sending a gallery of all the images of a property + The text description (i.e. : internal chatbot Property Show use)
    def send_property_info_post_interaction(subscriber, property)
        first_call = handle_manychat_response(send_content(subscriber, create_gallery_images_property(property)))
        if first_call[0]
            return handle_manychat_response(send_content(subscriber, create_show_text_card(property)))
        else
            return first_call
        end
    end

    # This method send a gallery of a favorites properties of a subscriber 
    def send_favorites_gallery_properties_card(subscriber, properties)
        return handle_manychat_response(send_content(subscriber, create_favorites_gallery_card(properties, subscriber)))
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
            headers: { 'Content-type' => "application/json", 'Authorization' => self.token }
        )
        request.run
        return handle_manychat_response(request.response)
    end

    #This method evaluate if a subscriber is 72hours past its last interaction
    #If so, we update him to is_active: false
    def is_last_interaction_borderline(mc_subs_infos)
        response = false
        a = Time.parse(mc_subs_infos['last_interaction']) + (72*60*60)
        b = Time.now
        if a < b
            sub = Subscriber.where(facebook_id: mc_subs_infos['id'])
            sub.update(is_active: false)
            response = true
        end
        return response
    end 

    private

    ###################################
    # [DING DONG x MANYCHAT] COMPONENTS
    ###################################

    # This method is building a single json_card for a property with the first image of the property
    def create_property_card(property, subscriber = nil)
        
        buttons = []
        if subscriber.nil?
            buttons.push(create_url_button_hash("Voir sur #{property.source}", property.link))
        else
            webhook = ENV['BASE_URL'] + "api/v1/subscribers/#{subscriber.id}/send/props/#{property.id}/details"
            buttons.push(create_dynamic_button_hash("🙋 En savoir plus", webhook, "GET"))
        end

        elements = []
        elements.push(create_message_element_hash(property.get_title, property.get_short_description, "https://via.placeholder.com/150", property.link, buttons))

        message_array = []
        message_array.push(create_message_card_hash("cards", elements, "square"))

        return message_array

    end
    
    # This method is building a json_gallery of cards for each property with the first image of each property 
    def create_gallery_card(properties, subscriber = nil)
        properties.length > 10 ? properties = properties[0..9] : nil
        elements = []
        properties.each do |property|
            buttons = []
        if subscriber.nil?
            buttons.push(create_url_button_hash("Voir sur #{property.source}", property.link))
        else
            webhook = ENV['BASE_URL'] + "api/v1/manychat/s/#{subscriber.id}/send/props/#{property.id}/details"
            puts webhook
            buttons.push(create_dynamic_button_hash("🙋 En savoir plus", webhook, "GET"))
        end
            elements.push(create_message_element_hash(property.get_title, property.get_short_description, property.get_cover, property.link, buttons))
            elements.length === 10 ? break : nil
        end

        message_array = []
        message_array.push(create_message_card_hash("cards", elements, "square"))

        return message_array
    end

    # This method is building a json_text of the description of the property 
    def create_show_text_card(property)
        buttons = []
        buttons.push(create_url_button_hash("Voir sur #{property.source}", property.link)) 
        if property.contact_number != nil && property.contact_number != "N/C"
            property.provider == "Particulier" ? caption = "Appeler le particulier" : caption = "Appeler l'agence"
            buttons.push(create_call_button_hash(caption, property.contact_number))
        end

        message_array = []
        message_hash = {}
        message_hash[:type] = "text"
        message_hash[:text] = property.get_long_description
        message_hash[:buttons] = buttons

        message_array.push(message_hash)

        return message_array
    end

    # This method is building a json_gallery of cards for each property in fav of a subscriber
    def create_favorites_gallery_card(properties, subscriber)
       
        if properties.length > 0 
            elements = []
            properties.each do |property|
                buttons = []
                webhook_1 = ENV['BASE_URL'] + "api/v1/manychat/s/#{subscriber.id}/send/props/#{property.id}/details"
                buttons.push(create_dynamic_button_hash("🙋 En voir plus", webhook_1, "GET"))

                favorite = Favorite.where(subscriber: subscriber, property: property).first
                webhook_2 = ENV['BASE_URL'] + "api/v1/favorites/#{favorite.id}"
                puts webhook_2
                buttons.push(create_dynamic_button_hash("⛔ Retirer des favoris", webhook_2, "DELETE"))

                elements.push(create_message_element_hash(property.get_title, property.get_short_description, property.get_images.first['url'], property.link, buttons))
                elements.length === 10 ? break : nil
            end

            message_array = []
            message_array.push(create_message_card_hash("cards", elements, "square"))
        else
            message_array = []
            text = "Oops, tu n'as aucune annonce en favori..."
            message_array.push(create_message_text_hash(text))
            
        end

        return message_array
    end

    # This method is bulding a json_gallery card of all images of a property
    def create_gallery_images_property(property)
        elements = []
        property.get_images.each do |img|
            elements.push(create_message_element_hash(property.get_title, property.get_short_description, img['url'], property.link))
            elements.length === 10 ? break : nil
        end
        puts elements
        message_array = []
        message_array.push(create_message_card_hash("cards", elements, "square"))

        return message_array
    end

    # This method is bulding a simple json card of a dynamic button with a caption
    def create_dynamic_text_card(btn_caption, webhook, method, text, body = {} )
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
    
    # Getter method for default quick_replies menu
    def get_default_qr
        qr = [{
            "type": "flow",
            "caption":"🏠 5 annonces",
            "target": "content20200217174711_881728"
        },
        {
            "type": "flow",
            "caption": "💸 Crédit",
            "target": "content20200218154133_249216"
        }, {
            "type": "flow",
            "caption": "🔨Travaux",
            "target": "content20200220114201_128307"
        },
        {
            "type": "flow",
            "caption": "🏘️ Estimation",
            "target": "content20200218153050_985402"
        },
        {
            "type": "flow",
            "caption": "💡 Conseil",
            "target": "content20200217174711_881728"
        },
        {
            "type": "flow",
            "caption": "⛔ Stop",
            "target": "system_unsubscribe20200210180528_020203"
        }]
      return qr
    end
    

    ##################################################################
    # STANDARD MANYCHAT COMPONENTS (Building unofficial ManyChat gem)
    ##################################################################

    #----------------
    # buttons
    #----------------
    def create_url_button_hash(caption, url)
        btn = {}
        btn[:type] = "url"
        btn[:caption] = caption 
        btn[:url] = url
        btn[:webview_size] = "full"
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
        header[:Authorization] = 'Bearer ' + ENV['BEARER_TOKEN']
        btn[:headers] = header
        btn[:payload] = body
        return btn
    end

    #----------------
    # elements
    #----------------
    def create_message_element_hash(title, subtitle, image_url, action_url, buttons_array=[])
        element = {}
        element[:title] = title
        element[:subtitle] = subtitle
        element[:image_url] = image_url
        element[:action_url] = action_url
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
                    "quick_replies": quick_replies_array
                }
            },
            "message_tag": "POST_PURCHASE_UPDATE"
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
            headers: { 'Content-type' => "application/json", 'Authorization' => self.token }
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