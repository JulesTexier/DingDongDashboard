class AddPasswordDigestToBroker < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :password_digest, :string, default: "$2a$12$De7bbVU.wYt16yE5EciYB.ZF8zvUFXWgduxGuFKYiEiwkWMwpEvqi"
  end
end
