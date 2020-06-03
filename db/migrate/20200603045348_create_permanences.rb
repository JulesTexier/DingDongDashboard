class CreatePermanences < ActiveRecord::Migration[6.0]
  def change
    create_table :permanences do |t|
      t.reference :subscriber
      t.reference :broker_shift
      
      t.timestamps
    end
  end
end
