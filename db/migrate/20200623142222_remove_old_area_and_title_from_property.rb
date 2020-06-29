class RemoveOldAreaAndTitleFromProperty < ActiveRecord::Migration[6.0]
  def change
    remove_column :properties, :title, :string
    remove_column :properties, :old_area, :string
  end
end
