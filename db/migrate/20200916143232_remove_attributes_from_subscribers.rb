class RemoveAttributesFromSubscribers < ActiveRecord::Migration[6.0]
  def up
    remove_column :subscribers, :max_price, :integer
    remove_column :subscribers, :min_surface, :integer
    remove_column :subscribers, :min_rooms_number, :integer
    remove_column :subscribers, :min_floor, :integer
    remove_column :subscribers, :min_price, :integer
    remove_column :subscribers, :max_sqm_price, :integer
    remove_column :subscribers, :home_type, :boolean
    remove_column :subscribers, :project_type, :string
    remove_column :subscribers, :min_elevator_floor, :integer
    remove_column :subscribers, :apartment_type, :boolean
    remove_column :subscribers, :balcony, :boolean
    remove_column :subscribers, :garden, :boolean
    remove_column :subscribers, :new_construction, :boolean
    remove_column :subscribers, :last_floor, :boolean
    remove_column :subscribers, :has_messenger, :boolean
  end

  def down
    add_column :subscribers, :max_price, :integer
    add_column :subscribers, :min_surface, :integer
    add_column :subscribers, :min_rooms_number, :integer
    add_column :subscribers, :min_floor, :integer
    add_column :subscribers, :min_price, :integer
    add_column :subscribers, :max_sqm_price, :integer
    add_column :subscribers, :home_type, :boolean
    add_column :subscribers, :project_type, :string
    add_column :subscribers, :min_elevator_floor, :integer
    add_column :subscribers, :apartment_type, :boolean
    add_column :subscribers, :balcony, :boolean
    add_column :subscribers, :garden, :boolean
    add_column :subscribers, :new_construction, :boolean
    add_column :subscribers, :last_floor, :boolean
    add_column :subscribers, :has_messenger, :boolean
  end
end
