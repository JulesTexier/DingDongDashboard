require "dotenv/load"
require "typhoeus"

class Trello
  attr_reader :token

  def initialize
    @token = "key=#{ENV['TRELLO_KEY']}&token=#{ENV['TRELLO_SECRET']}"
  end

  def add_comment_to_card(card_id, comment)
    
  end

  def add_new_lead_on_trello(lead)
    
    # 1• Create card on tello Board 
    list_id = lead.broker.trello_lead_list_id
    params = {}
    params[:name] = lead_hash[:name]
    params[:desc] = lead.trello_description
    params[:pos] = 'top'
    params[:due] = Time.now + 15.minutes
    params[:idMembers] = b.trello_id
    new_card_response = @trello.create_new_card(list_id, params)

    # 2• Add checklist 'Action' to created card
    card_id = JSON.parse(new_card_response.body)["id"]
    lead.update(trello_id_card: card_id)
    new_checklist_response = @trello.add_checklist_to_card(card_id)

    # 3• Add first action on the checklist
    checklist_id = JSON.parse(new_checklist_response.body)["id"]
    check_items_params = {}
    check_items_params[:name] = "Rentrer en contact avec #{lead.name}"
    new_checkitem_response = @trello.add_checkitem_to_checklist(checklist_id, check_items_params)

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
      "https://api.trello.com/1/cards/#{card_id}/checklists?" + trello_auth,
      method: :post,
      params: checklist_params
    )
    response = request.run
  end

  def add_checkitem_to_checklist(checklist_id, params)
    request = Typhoeus::Request.new(
      "https://api.trello.com/1/checklists/#{checklist_id}/checkItems?" + trello_auth,
      method: :post,
      params: params
    )
    response = request.run
  end

end