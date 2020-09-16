class DropSelection < ActiveRecord::Migration[6.0]
  def change
    drop_table :selections do |t|
      t.belongs_to :hunter_search
      t.belongs_to :property
      t.timestamps null: false
    end
  end
end
