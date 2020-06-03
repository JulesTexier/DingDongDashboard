class CreatePermanences < ActiveRecord::Migration[6.0]
  def change
    create_table :permanences do |t|
      t.subscriber :subscriber
      t.broker_shift :broker_shift

      t.timestamps
    end
  end
end
