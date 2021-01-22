class AddSpecificAreaBrokersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :specific_area_broker do |t|
      t.belongs_to :broker
      t.belongs_to :area
      t.timestamps
    end
  end
end
