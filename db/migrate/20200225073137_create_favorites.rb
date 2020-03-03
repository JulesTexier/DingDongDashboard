class CreateFavorites < ActiveRecord::Migration[6.0]
  def change
    create_table :favorites do |t|
      t.belongs_to :subscriber
      t.belongs_to :property
      t.timestamps
    end
  end
end
