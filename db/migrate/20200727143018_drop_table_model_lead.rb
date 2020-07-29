class DropTableModelLead < ActiveRecord::Migration[6.0]
  def change
    drop_table :leads do |t|
      t.string :firstname
      t.string :phone
      t.string :email
      t.boolean :has_messenger
      t.integer :min_surface
      t.integer :max_price
      t.string :project_type
      t.text :areas
      t.text :additional_question
      t.text :specific_criteria
      t.string :source
      t.timestamps null: false
      t.string :status
      t.bigint :broker_id
      t.string :trello_id_card
      t.string :lastname
      t.integer :min_rooms_number
    end
  end
end
