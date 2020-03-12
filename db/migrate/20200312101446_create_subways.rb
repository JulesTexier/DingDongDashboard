class CreateSubways < ActiveRecord::Migration[6.0]
  def change
    create_table :subways do |t|
      t.string :name
      t.integer :line, array: true, default: []
      t.timestamps
    end
  end
end
