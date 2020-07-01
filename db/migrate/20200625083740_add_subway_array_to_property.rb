class AddSubwayArrayToProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :subway_infos, :text
  end
end
