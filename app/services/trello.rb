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
    params[:name] = lead.name
    params[:desc] = lead.trello_description
    params[:pos] = 'top'
    params[:due] = Time.now + 15.minutes
    params[:idMembers] = lead.broker.trello_id
    new_card_response = create_new_card(list_id, params)
    return false if new_card_response.code != 200
    
    # 2• Add checklist 'Action' to created card
    card_id = JSON.parse(new_card_response.body)["id"]
    lead.update(trello_id_card: card_id)
    new_checklist_response = add_checklist_to_card(card_id)
    return false if new_checklist_response.code != 200

    
    # 3• Add first action on the checklist
    checklist_id = JSON.parse(new_checklist_response.body)["id"]
    check_items_params = {}
    check_items_params[:name] = "Rentrer en contact avec #{lead.name}"
    new_checkitem_response = add_checkitem_to_checklist(checklist_id, check_items_params)
    return false if new_checkitem_response.code != 200
    return true
  end
  
  def add_comment_to_card(card_id, comment)
    
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

end