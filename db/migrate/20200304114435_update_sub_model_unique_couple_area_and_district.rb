class UpdateSubModelUniqueCoupleAreaAndDistrict < ActiveRecord::Migration[6.0]
  def change
    add_index :selected_areas, [:subscriber_id, :area_id], unique: true
    add_index :selected_districts, [:subscriber_id, :district_id], unique: true
  end
end
