class CreateHunterSearches < ActiveRecord::Migration[6.0]
  def change
    create_table :hunter_searches do |t|
      t.string :research_name
      t.text :areas, array: true, default: []
      t.integer :min_floor, default: 0
      t.boolean :has_elevator, default: nil
      t.integer :min_elevator_floor, default: 0
      t.integer :surface
      t.integer :rooms_number
      t.integer :max_price
      t.belongs_to :hunter
      t.timestamps
    end
  end
end
