class RemoveDeviseAttributesForBroker < ActiveRecord::Migration[6.0]
  def change
    remove_column :brokers, :reset_password_token
    remove_column :brokers, :reset_password_sent_at
    remove_column :brokers, :encrypted_password
    remove_column :brokers, :remember_created_at
    remove_column :brokers, :sign_in_count
    remove_column :brokers, :current_sign_in_at
    remove_column :brokers, :last_sign_in_at
    remove_column :brokers, :current_sign_in_ip
    remove_column :brokers, :last_sign_in_ip
    # remove_index :brokers, name: "index_brokers_on_reset_password_token"

  end
end
