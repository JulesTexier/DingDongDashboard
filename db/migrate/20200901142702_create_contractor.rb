class CreateContractor < ActiveRecord::Migration[6.0]
  def change
    create_table :contractors do |t|
      t.string :firstname
      t.string :lastname
      t.string :profile_picture
      t.string :phone
      t.string :company
      t.string :email
    end
  end
end
