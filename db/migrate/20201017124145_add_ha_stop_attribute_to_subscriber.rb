class AddHaStopAttributeToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :has_stopped, :boolean, default: false
  end
end
