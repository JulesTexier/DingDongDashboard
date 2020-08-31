class RenameColumnInResearches < ActiveRecord::Migration[6.0]
  def change
    rename_column :researches, :zone, :agglomeration
  end
end
