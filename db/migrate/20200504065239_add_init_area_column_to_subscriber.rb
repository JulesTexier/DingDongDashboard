class AddInitAreaColumnToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :initial_areas, :string
  end
end
