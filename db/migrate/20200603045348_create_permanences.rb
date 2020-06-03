class CreatePermanences < ActiveRecord::Migration[6.0]
  def change
    create_table :permanences do |t|
      t.references :broker
      t.references :broker_shift
      
      t.timestamps
    end
  end
end
