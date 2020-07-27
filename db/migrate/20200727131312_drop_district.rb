class DropDistrict < ActiveRecord::Migration[6.0]
  def change
    drop_table :districts do |t|
      t.string :name
      t.string :description
      t.timestamps null: false
    end
  end
end
