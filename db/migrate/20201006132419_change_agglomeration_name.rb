class ChangeAgglomerationName < ActiveRecord::Migration[6.0]
  def self.up
    rename_column :researches, :agglomeration, :soon_deleted_agglomeration
  end

  def self.down
    rename_column :researches, :soon_deleted_agglomeration, :agglomeration
  end
end
