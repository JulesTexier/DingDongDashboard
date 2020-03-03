class ChangeSubscriberIsActiveDefaultValue < ActiveRecord::Migration[6.0]
  def change
    change_column :subscribers, :is_active, :boolean, default: true
    change_column :subscribers, :min_elevator_floor, :integer, default: 0
    change_column :subscribers, :min_floor, :integer, default: 0
  end
end
