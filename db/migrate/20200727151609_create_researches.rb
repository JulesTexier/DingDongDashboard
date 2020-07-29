class CreateResearches < ActiveRecord::Migration[6.0]
  def change
    create_table :researches do |t|
      t.string :research_name, default: nil
      t.string :zone, default: nil
      t.integer :min_floor, default: 0
      t.boolean :has_elevator, default: nil
      t.integer :min_elevator_floor, default: 0
      t.integer :min_surface
      t.integer :min_rooms_number
      t.integer :max_price
      t.integer :min_price
      t.integer :max_sqm_price
      t.boolean :is_active, default: true
      t.boolean :balcony, default: false
      t.boolean :terrace, default: false
      t.boolean :garden, default: false
      t.boolean :new_construction, default: false
      t.boolean :last_floor, default: false
      t.boolean :home_type, default: true
      t.boolean :apartment_type, default: true
      t.belongs_to :hunter, optionnal: true
      t.belongs_to :subscriber, optionnal: true
      t.timestamps
    end
  end
end
