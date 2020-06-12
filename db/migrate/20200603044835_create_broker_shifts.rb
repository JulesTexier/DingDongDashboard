class CreateBrokerShifts < ActiveRecord::Migration[6.0]
  def change
    create_table :broker_shifts do |t|
      t.integer :starting_hour
      t.integer :ending_hour
      t.integer :day
      t.string :name
      t.string :shift_type

      t.timestamps
    end
  end
end
