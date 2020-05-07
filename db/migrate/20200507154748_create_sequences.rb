class CreateSequences < ActiveRecord::Migration[6.0]
  def change
    create_table :sequences do |t|
      t.string :name
      t.string :sender_email
      t.string :sender_name
      t.string :source
      t.boolean :is_active
      t.text :trigger_ads, array: true, default: []
      t.timestamps
    end
  end
end
