class DropHunterSearchArea < ActiveRecord::Migration[6.0]
  def change
    drop_table :hunter_search_areas do |t|
      t.belongs_to :hunter_search
      t.belongs_to :area
      t.timestamps null: false
    end
  end
end
