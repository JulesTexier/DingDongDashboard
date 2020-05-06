class AddAliasEmailToBroker < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :alias_email, :string
  end
end
