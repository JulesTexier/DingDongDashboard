class UpdateHunterSearchAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :hunter_searches, :min_price, :integer
    add_column :hunter_searches, :max_sqm_price, :integer
    rename_column :hunter_searches, :surface, :min_surface
    rename_column :hunter_searches, :rooms_number, :min_rooms_number
  end
end
