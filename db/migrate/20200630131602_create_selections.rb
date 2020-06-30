class CreateSelections < ActiveRecord::Migration[6.0]
  def change
    create_table :selections do |t|
      t.references :hunter_search, foreign_key: true
      t.references :property, foreign_key: true
      t.timestamps
    end
  end
end
