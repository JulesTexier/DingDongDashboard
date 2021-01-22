class AddAttributesToBroker < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :accept_leads, :boolean, default: true
    add_column :brokers, :is_director, :boolean, default: false
  end
end
