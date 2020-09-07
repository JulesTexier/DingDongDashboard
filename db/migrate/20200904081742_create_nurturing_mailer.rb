class CreateNurturingMailer < ActiveRecord::Migration[6.0]
  def change
    create_table :nurturing_mailers do |t|
      t.string :name
      t.integer :time_frame
      t.string :template
      t.boolean :is_active, default: false
      t.text :description
    end
  end
end
