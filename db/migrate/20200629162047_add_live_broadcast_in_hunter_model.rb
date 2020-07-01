class AddLiveBroadcastInHunterModel < ActiveRecord::Migration[6.0]
  def change
    add_column :hunters, :live_broadcast, :boolean, default: true
  end
end
