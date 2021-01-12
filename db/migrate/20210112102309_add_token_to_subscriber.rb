class AddTokenToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :auth_token, :string
    add_index :subscribers, :auth_token, unique: true
  end
end
