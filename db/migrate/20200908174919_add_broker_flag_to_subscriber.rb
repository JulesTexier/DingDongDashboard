class AddBrokerFlagToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :is_broker_affiliated, :boolean, default: false
  end
end
