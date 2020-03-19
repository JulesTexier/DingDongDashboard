class AddImageArrayInProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :images, :text, array: true, default: []
  end
end
