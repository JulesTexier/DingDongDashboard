class AddBrokerStatusToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :broker_status, :string, default: "Non traité"
    add_column :subscribers, :broker_comment, :text, default: ""
  end
end
