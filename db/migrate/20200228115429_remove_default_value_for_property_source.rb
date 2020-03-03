class RemoveDefaultValueForPropertySource < ActiveRecord::Migration[6.0]
  def change
    change_column :properties, :source, :string, default: nil
  end
end
