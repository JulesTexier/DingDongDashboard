class CreateBrokers < ActiveRecord::Migration[6.0]
  def change
    create_table :brokers do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :agency
      t.string :trello_lead_list_id
      t.string :trello_board_id

      t.timestamps
    end
  end
end
