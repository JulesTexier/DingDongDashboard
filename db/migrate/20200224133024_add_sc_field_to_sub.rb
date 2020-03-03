class AddScFieldToSub < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :max_price, :integer
    add_column :subscribers, :min_surface, :integer
    add_column :subscribers, :min_rooms_number, :integer
    add_column :subscribers, :min_floor, :integer
    add_column :subscribers, :min_elevator_floor, :integer
  end
end
