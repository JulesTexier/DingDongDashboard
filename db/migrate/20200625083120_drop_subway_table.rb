class DropSubwayTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :subways
  end
end
