class AddSpecificAreaBrokersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :specific_area_broker_agencies do |t|
      t.belongs_to :broker_agency
      t.belongs_to :area
      t.timestamps
    end
  end
end
