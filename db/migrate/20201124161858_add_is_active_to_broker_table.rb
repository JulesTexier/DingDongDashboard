class AddIsActiveToBrokerTable < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :is_active, :boolean, default: true
    add_column :brokers, :min_monthly_contact, :integer, default: 0
    add_column :brokers, :max_monthly_contact, :integer, default: 100
  end
end
