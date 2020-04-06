class CreateLeads < ActiveRecord::Migration[6.0]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.boolean :has_messenger
      t.integer :min_surface
      t.integer :max_price
      t.string :project_type
      t.array :areas
      t.text :additional_question
      t.string :specific_criteria=textsource

      t.timestamps
    end
  end
end
