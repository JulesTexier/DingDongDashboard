class DropHunterTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :hunters do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :company
      t.boolean :live_broadcast
      t.timestamps null: false
    end
  end
end
