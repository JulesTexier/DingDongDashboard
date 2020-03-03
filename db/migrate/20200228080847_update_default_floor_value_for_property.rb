class UpdateDefaultFloorValueForProperty < ActiveRecord::Migration[6.0]
  def change
    change_column :properties, :floor, :integer, default: 1000
  end
end
