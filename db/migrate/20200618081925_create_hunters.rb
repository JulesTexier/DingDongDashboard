class CreateHunters < ActiveRecord::Migration[6.0]
  def change
    create_table :hunters do |t|
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :company

      t.timestamps
    end
  end
end
