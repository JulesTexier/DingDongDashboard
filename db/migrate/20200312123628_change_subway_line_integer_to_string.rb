class ChangeSubwayLineIntegerToString < ActiveRecord::Migration[6.0]
  def change
    change_column :subways, :line, :string
  end
end
