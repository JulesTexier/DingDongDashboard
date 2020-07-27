class DropSelectedDistrict < ActiveRecord::Migration[6.0]
  def change
    drop_table :selected_districts do |t|
      t.belongs_to :district
      t.belongs_to :subscriber
      t.timestamps
    end
  end
end
