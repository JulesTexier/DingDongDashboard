class DropHunterSearch < ActiveRecord::Migration[6.0]
  def change
    drop_table :hunter_searches do |t|
      t.belongs_to :hunter
      t.timestamps null: false
    end
  end
end
