class AddPassWordToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :password_digest, :string
  end
end
