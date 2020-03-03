class CreatePropertyImages < ActiveRecord::Migration[6.0]
  def change
    create_table :property_images do |t|
      t.string :url
      t.belongs_to :property

      t.timestamps
    end
  end
end
