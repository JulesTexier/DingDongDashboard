class UpdateDefaultMinFloorElevatorResearch < ActiveRecord::Migration[6.0]
  def change
    change_column :researches, :min_elevator_floor, :integer, default: nil
  end
end
