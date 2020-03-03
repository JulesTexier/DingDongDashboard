class UpdatePropertyModel < ActiveRecord::Migration[6.0]
  def change
    change_column :properties, :floor, :integer, default: nil
    remove_column :properties, :elevator
    add_column :properties, :has_elevator, :boolean, default: nil
  end
end
