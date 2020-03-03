class CreateProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :properties do |t|
      t.integer :price
      t.string :area
      t.string :title
      t.text :description
      t.string :link
      t.integer :rooms_number
      t.integer :bedrooms_number
      t.integer :surface
      t.string :flat_type
      t.string :agency_name
      t.string :agency_number
      t.string :reference
      t.string :source
      t.string :provider
      t.string :street
      t.integer :floor
      t.string :elevator
      t.string :renovated
      t.boolean :has_been_processed

      t.timestamps
    end
  end
end
