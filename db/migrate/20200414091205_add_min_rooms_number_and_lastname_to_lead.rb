class AddMinRoomsNumberAndLastnameToLead < ActiveRecord::Migration[6.0]
  def change
    rename_column :leads, :name, :firstname
    add_column :lead, :lastname, :string
    add_column :leads, :min_rooms_number, :integer
  end
end
