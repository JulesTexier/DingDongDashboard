class CreateSubscriberSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriber_sequences do |t|
      t.references :sequence, null: false, foreign_key: true
      t.references :subscriber, null: false, foreign_key: true
      t.timestamps
    end
  end
end
