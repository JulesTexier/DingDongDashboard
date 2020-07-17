class AddPropertyTypeToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :home_type, :string, default: false
    add_column :subscribers, :apartment_type, :string, default: false
    add_column :hunter_searches, :home_type, :string, default: false
    add_column :hunter_searches, :apartment_type, :string, default: false
  end
end
