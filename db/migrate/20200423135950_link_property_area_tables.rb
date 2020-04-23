class LinkPropertyAreaTables < ActiveRecord::Migration[6.0]
  def change
    rename_column :properties, :area, :old_area
    add_column :properties, :area_id, :integer
    add_foreign_key :properties, :areas
  end
end
