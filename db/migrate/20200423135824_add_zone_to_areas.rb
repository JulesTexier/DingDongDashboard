class AddZoneToAreas < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :zone, :string
  end
end
