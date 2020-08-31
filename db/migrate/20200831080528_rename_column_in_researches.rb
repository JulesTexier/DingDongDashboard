class RenameColumnInResearches < ActiveRecord::Migration[6.0]
  def change
    rename_column :researches, :zone, :agglomeration
    add_column :researches, :email_flux, :boolean
    add_column :researches, :messenger_flux, :boolean
  end
end
