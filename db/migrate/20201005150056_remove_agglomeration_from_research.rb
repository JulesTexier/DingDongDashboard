class RemoveAgglomerationFromResearch < ActiveRecord::Migration[6.0]
  def up
    remove_column :researches, :agglomeration, :string
  end

  def down
    add_column :researches, :agglomeration, :string
  end
end
