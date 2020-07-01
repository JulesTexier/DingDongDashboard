class AddIsActiveBooleanToHunterSearch < ActiveRecord::Migration[6.0]
  def change
    add_column :hunter_searches, :is_active, :boolean, default: true
  end
end
