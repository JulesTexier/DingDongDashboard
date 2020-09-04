class AddDescriptionToProfessionals < ActiveRecord::Migration[6.0]
  def change
    add_column :notaries, :description, :text
    add_column :contractors, :description, :text
  end
end
