require "dotenv/load"
require "typhoeus"

class Trello
  attr_reader :token

  def initialize
    @token = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"
  end

  def add_new_lead_on_trello(lead)

    # 1• Create card on tello Board 
    list_id = lead.broker.trello_lead_list_id
    params = {}
    params[:name] = lead.get_fullname
    params[:desc] = lead.trello_description
    params[:pos] = 'top'
    params[:due] = Time.now.in_time_zone("Paris") + 15.minutes
    params[:idMembers] = lead.broker.trello_id
    new_card_response = create_new_card(list_id, params)
    return false if new_card_response.code != (200 || 204)
    
    # 2• Add checklist 'Action' to created card
    card_id = JSON.parse(new_card_response.body)["id"]
    lead.update(trello_id_card: card_id)
    new_checklist_response = add_checklist_to_card(card_id)
    return false if new_checklist_response.code != (200 || 204)

    
    # 3• Add first action on the checklist
    checklist_id = JSON.parse(new_checklist_response.body)["id"]
    check_items_params = {}
    check_items_params[:name] = "Rentrer en contact avec #{lead.get_fullname} - @#{lead.broker.trello_username}"
    new_checkitem_response = add_checkitem_to_checklist(checklist_id, check_items_params)
    return false if new_checkitem_response.code != (200 || 204)
    
    # 4 • Send notification email to the broker
    PostmarkMailer.send_new_lead_notification_to_broker(lead).deliver_now if !lead.broker.email.nil?
    return true
    
  end

  def add_lead_on_trello_no_messenger(lead)

    # 1 • Attach Greg as broker to this lead 
    lead.update(broker: Broker.get_broker_by_username("gregrouxeloldra"))

    # 2 • Add lead on the adequate Greg's list
    # params = {}
    # params[:name] = lead.get_fullname
    # params[:desc] = lead.trello_description
    # params[:pos] = 'top'
    # # params[:due] = Time.now.in_time_zone("Paris") + 15.minutes
    # params[:idMembers] = lead.broker.trello_id
    # new_card_response = create_new_card("5e9add8a8122483bba7a7f77", params)
    # return false if new_card_response.code != 200
    
    # 3 • Handle support for the lead 
    PostmarkMailer.send_email_to_lead_with_no_messenger(lead).deliver_now
  end
  
  def add_comment_to_card(card_id, comment) 
  end

  def get_trello_card_broker(card_id)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}/members?" + @token,
      method: :get
    )
    response = request.run
    broker_trello_id = JSON.parse(response.body)[0]["id"]
    b = Broker.where(trello_id: broker_trello_id).first
  end

  def add_comment_to_lead_card(lead, comment)
    card_id = lead.trello_id_card
    params = {}
    params[:text] = comment + " @#{lead.broker.trello_username}"
    if !card_id.nil? && !lead.broker.trello_username.nil?
      add_comment_to_card(card_id, params)
    end
  end

  def update_trello_card_greg_list(card_id)
    response = update_list_of_a_card(card_id, "5e95ca5e56f1c580127eb9c0")
    if response.code == 200 
      return true
    else 
      return false
    end
  end

  def add_label_old_user(lead)
    # Add label on card 
    label_id = get_label_id_by_name(lead.broker.trello_board_id, "UTILISATEUR HISTORIQUE DING DONG")
    add_label_to_card(lead.trello_id_card, label_id)
    # Add comment on carte to advise broker 
    params = {}
    params[:text] = "NE PAS ENVOYER LE MAIL DING DONG \u000A Utilisateur déjà sur le chatbot Ding Dong mais n'ayant jamais pris rdv avec un courtier Ding Dong" + " @#{lead.broker.trello_username}"
    add_comment_to_card(lead.trello_id_card, params)
  end

  private 
  
  def create_new_card(list_id, params)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards?idList=#{list_id}&" + @token,
      method: :post,
      params: params
    )
    response = request.run
  end

  def add_checklist_to_card(card_id)
    checklist_params = {}
    checklist_params[:name] = "ACTIONS"
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}/checklists?" + @token,
      method: :post,
      params: checklist_params
    )
    response = request.run
  end

  def add_checkitem_to_checklist(checklist_id, params)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/checklists/#{checklist_id}/checkItems?" + @token,
      method: :post,
      params: params
    )
    response = request.run
  end

  def update_list_of_a_card(card_id, new_list_id)
    params = {}
    params[:idList] = new_list_id
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}?" + @token,
      method: :put,
      params: params
    )
    response = request.run
  end

  def add_label_to_card(card_id, label_id)
    checklist_params = {}
    checklist_params[:value] = label_id
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}/idLabels?" + @token,
      method: :post,
      params: checklist_params
    )
    response = request.run
  end

  def add_comment_to_card(card_id, params)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}/actions/comments?" + @token,
      method: :post,
      params: params
    )
    response = request.run
  end

  def get_label_id_by_name(board_id, name)
    label_id = nil
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/boards/#{board_id}/labels?" + @token,
      method: :get
    )
    response = request.run
    labels = JSON.parse(response.body)
    labels.each do |label|
      label_id = label["id"] if label["name"] == name 
    end
    return label_id
  end

end