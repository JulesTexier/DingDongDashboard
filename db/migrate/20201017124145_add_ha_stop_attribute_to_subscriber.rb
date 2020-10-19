class AddHaStopAttributeToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :has_stopped, :boolean, default: false
    add_column :subscribers, :has_stopped_at, :datetime
  end
end
