class DropPropertySubwayJoinTable < ActiveRecord::Migration[6.0]
  def change
    drop_join_table :properties, :subways, table_name: :property_subways
  end
end
