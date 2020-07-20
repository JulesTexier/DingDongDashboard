class AddPropertyTypeToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :home_type, :boolean, default: true
    add_column :subscribers, :apartment_type, :boolean, default: true
    add_column :hunter_searches, :home_type, :boolean, default: true
    add_column :hunter_searches, :apartment_type, :boolean, default: true
  end
end
