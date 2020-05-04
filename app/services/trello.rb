require "dotenv/load"
require "typhoeus"

class Trello
  attr_reader :token

  def initialize
    @token = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"
  end

  def add_new_user_on_trello(user)

    # 1• Create card on tello Board 
    list_id = user.broker.trello_lead_list_id
    params = {}
    params[:name] = user.get_fullname
    params[:desc] = user.trello_description
    params[:pos] = 'top'
    new_card_response = create_new_card(list_id, params)
    return false if new_card_response.code != (200 || 204)
    
    # 2• Add checklist 'Action' to created card
    card_id = JSON.parse(new_card_response.body)["id"]
    user.update(trello_id_card: card_id)
    new_checklist_response = add_checklist_to_card(card_id)
    return false if new_checklist_response.code != (200 || 204)

    
    # 3• Add first action on the checklist
    checklist_id = JSON.parse(new_checklist_response.body)["id"]
    check_items_params = {}
    check_items_params[:name] = "Rentrer en contact avec #{user.get_fullname}"
    new_checkitem_response = add_checkitem_to_checklist(checklist_id, check_items_params)
    return false if new_checkitem_response.code != (200 || 204)

    # 4• Add dedicated label if old user
    if !user.status.nil?
      if user.status.include?("old user")
        add_label_old_user(user)
      end
    end
    
    return true
    
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

  def add_comment_to_user_card(user, comment)
    card_id = user.trello_id_card
    params = {}
    params[:text] = comment
    params[:text] += " @#{lead.broker.trello_username }" if !lead.broker.trello_username.nil?
    if !card_id.nil? 
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

  def add_label_old_user(user)
    # Add label on card 
    label_id = get_label_id_by_name(user.broker.trello_board_id, "UTILISATEUR HISTORIQUE DING DONG")
    add_label_to_card(user.trello_id_card, label_id)
    # Add comment on carte to advise broker 
    params = {}
    params[:text] = "NE PAS ENVOYER LE MAIL DING DONG \u000A Utilisateur déjà sur le chatbot Ding Dong mais n'ayant jamais pris rdv avec un courtier Ding Dong"
    add_comment_to_card(user.trello_id_card, params)
  end

  def archive_card_after_user_transfer(old_card_id, new_broker)
    params = {}
    params[:closed] = true
    params[:desc] = "Transféré à #{new_broker.firstname}, le #{Time.now.in_time_zone("Paris")}"
    response = update_card_list(old_card_id, params)
    response.code == 200 ? true : false
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

  def update_card_list(card_id, params)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/cards/#{card_id}/?" + @token,
      method: :put,
      params: params
    )
    response = request.run
  end

end