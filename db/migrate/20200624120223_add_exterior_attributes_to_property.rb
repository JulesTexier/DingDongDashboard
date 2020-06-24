class AddExteriorAttributesToProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :is_new_construction, :boolean, default: nil
    add_column :properties, :is_last_floor, :boolean, default: nil
  end
end
