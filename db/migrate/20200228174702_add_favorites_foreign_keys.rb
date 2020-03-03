class AddFavoritesForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :favorites, :properties
    add_foreign_key :favorites, :subscribers
  end
end
