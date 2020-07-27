class DestroyPropertyImageTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :property_images do |t|
      t.string :url
      t.belongs_to :property
      t.timestamps null: false
    end
  end
end
