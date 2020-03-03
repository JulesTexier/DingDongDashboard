class CreateSelectedAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :selected_areas do |t|
      t.belongs_to :subscriber
      t.belongs_to :area
      t.timestamps
    end
  end
end
