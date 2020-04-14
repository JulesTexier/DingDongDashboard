class AddBrokerAndTrelloIdCardToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscribers, :broker, index: true
    add_column :subscribers, :trello_id_card, :string 
  end
end
