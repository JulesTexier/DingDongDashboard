class AddExteriorAttrToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :balcony, :boolean, default: false
    add_column :subscribers, :terrace, :boolean, default: false
    add_column :subscribers, :garden, :boolean, default: false
    add_column :subscribers, :new_construction, :boolean, default: false
  end
end
