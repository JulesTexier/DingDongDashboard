class UpdateFavoritesAddUniqueness < ActiveRecord::Migration[6.0]
  def change
    add_index :favorites, [:subscriber_id, :property_id], unique: true
  end
end
