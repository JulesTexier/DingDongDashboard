class CreateAgglomeration < ActiveRecord::Migration[6.0]
  def change
    create_table :agglomerations do |t|
      t.string :name
      t.string :image_url
      t.boolean :is_active, default: false
    end
  end
end
