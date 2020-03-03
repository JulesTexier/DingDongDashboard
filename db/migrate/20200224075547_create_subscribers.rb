class CreateSubscribers < ActiveRecord::Migration[6.0]
  def change
    create_table :subscribers do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :facebook_id
      t.boolean :is_active

      t.timestamps
    end
  end
end
