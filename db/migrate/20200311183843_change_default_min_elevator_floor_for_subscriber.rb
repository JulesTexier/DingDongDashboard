class ChangeDefaultMinElevatorFloorForSubscriber < ActiveRecord::Migration[6.0]
  def change
    change_column :subscribers, :min_elevator_floor, :string, default: nil
  end
end
