class CreatePropertySubways < ActiveRecord::Migration[6.0]
  def change
    create_table :property_subways do |t|
      t.belongs_to :property
      t.belongs_to :subway
      t.index [:property_id, :subway_id], unique: true
      t.timestamps
    end
  end
end