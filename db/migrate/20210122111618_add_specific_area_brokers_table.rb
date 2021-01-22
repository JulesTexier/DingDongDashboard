class AddSpecificAreaBrokersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :specific_area_brokers do |t|
      t.belongs_to :broker
      t.belongs_to :area
      t.timestamps
    end
  end
end
