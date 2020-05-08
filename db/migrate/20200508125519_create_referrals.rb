class CreateReferrals < ActiveRecord::Migration[6.0]
  def change
    create_table :referrals do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.string :email
      t.string :referral_type

      t.timestamps
    end
  end
end
