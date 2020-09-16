class DropFavorites < ActiveRecord::Migration[6.0]
  def change
    drop_table :favorites do |t|
      t.belongs_to :subscriber
      t.belongs_to :property
      t.timestamps null: false
    end
  end
end
