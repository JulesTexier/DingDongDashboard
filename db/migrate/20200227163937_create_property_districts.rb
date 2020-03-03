class CreatePropertyDistricts < ActiveRecord::Migration[6.0]
  def change
    create_table :property_districts do |t|
      t.belongs_to :district
      t.belongs_to :property

      t.timestamps
    end
  end
end
