class CreateStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :statuses do |t|
      t.string :name
      t.text :description
      t.string :status_type

      t.timestamps
    end
  end
end
