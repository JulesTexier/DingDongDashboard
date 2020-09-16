class DropSelectedArea < ActiveRecord::Migration[6.0]
  def change
    drop_table :selected_areas do |t|
      t.belongs_to :area
      t.belongs_to :subscriber
      t.timestamps null: false
    end
  end
end
