class UpdateDefaultPropertyFieldsValues < ActiveRecord::Migration[6.0]
  def change
    change_column :properties, :flat_type, :string, default: "N/C"
    rename_column :properties, :agency_number, :contact_number
    change_column :properties, :contact_number, :string, default: "N/C"
    change_column :properties, :agency_name, :string, default: "N/C"
    change_column :properties, :source, :string, default: "N/C"
    change_column :properties, :provider, :string, default: "N/C"
    change_column :properties, :street, :string, default: "N/C"
    change_column :properties, :floor, :integer, default: -1000
    change_column :properties, :elevator, :string, default: "N/C"
    change_column :properties, :renovated, :string, default: "N/C"
    change_column :properties, :has_been_processed, :boolean, default: false
  end
end
