class CreatePropertyHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :property_histories do |t|
      t.integer "price"
      t.text "description"
      t.string "link"
      t.string "area"
      t.integer "rooms_number"
      t.integer "bedrooms_number"
      t.integer "surface"
      t.string "flat_type"
      t.string "agency_name"
      t.string "contact_number"
      t.string "reference"
      t.string "source"
      t.string "method_name"
      t.string "error"
      t.text "images", default: [], array: true
      t.timestamps
    end
  end
end
