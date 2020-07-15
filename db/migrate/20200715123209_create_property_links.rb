class CreatePropertyLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :property_links do |t|
      t.references :property, index: true, foreign_key: true
      t.string :link
      t.string :source
      t.text :description
      t.text :images, array: true, default: []
      t.string :method_name
      t.timestamps
    end
  end
end
