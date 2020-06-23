class CreateHunterSearchAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :hunter_search_areas do |t|
      t.belongs_to :hunter_search
      t.belongs_to :area
      t.timestamps
    end
  end
end
