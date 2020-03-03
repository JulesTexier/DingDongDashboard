class ChangeDistrictDescTypeToText < ActiveRecord::Migration[6.0]
  def change
    change_column :districts, :description, :text
  end
end
