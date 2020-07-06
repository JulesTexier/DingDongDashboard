class AddAttributesForExteriorCriterias < ActiveRecord::Migration[6.0]
  def change
    add_column :hunter_searches, :balcony, :boolean,  default: false
    add_column :hunter_searches, :terrace, :boolean,  default: false
    add_column :hunter_searches, :garden, :boolean, default: false
    add_column :hunter_searches, :new_construction, :boolean,  default: false
    add_column :hunter_searches, :last_floor, :boolean,  default: false
  end
end
