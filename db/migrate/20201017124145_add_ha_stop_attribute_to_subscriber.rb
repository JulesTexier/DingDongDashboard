class AddHaStopAttributeToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :has_stop, :boolean, default: false
  end
end
