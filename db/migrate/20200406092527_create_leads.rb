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
      t.text :areas
      t.text :additional_question
      t.text :specific_criteria
      t.string :source

      t.timestamps
    end
  end
end
