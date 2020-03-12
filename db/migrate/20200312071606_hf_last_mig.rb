class HfLastMig < ActiveRecord::Migration[6.0]
  def change
    change_column :subscribers, :min_elevator_floor, :integer, using: 'min_elevator_floor::integer'
  end
end
