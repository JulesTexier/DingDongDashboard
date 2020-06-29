class AddExteriorAttributeToProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :has_terrace, :boolean, default: nil
    add_column :properties, :has_garden, :boolean, default: nil
    add_column :properties, :has_balcony, :boolean, default: nil
  end
end
