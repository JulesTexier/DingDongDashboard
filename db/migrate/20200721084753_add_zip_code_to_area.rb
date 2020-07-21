class AddZipCodeToArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :zip_code, :string 
  end
end
