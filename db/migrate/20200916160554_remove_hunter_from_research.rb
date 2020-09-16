class RemoveHunterFromResearch < ActiveRecord::Migration[6.0]
  def change
    remove_reference :researches, :hunter
  end
end
