class AddBrokerCheckboxToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :checked_by_broker, :boolean, default: false
  end
end
