class AddTrelloUsernameToBroker < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :trello_username, :string
  end
end
