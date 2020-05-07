class CreateSequenceSteps < ActiveRecord::Migration[6.0]
  def change
    create_table :sequence_steps do |t|
      t.integer :step
      t.string :name
      t.text :description
      t.string :sequence_type
      t.integer :time_frame
      t.string :template
      t.references :sequence, null: false, foreign_key: true
      t.timestamps
    end
  end
end
