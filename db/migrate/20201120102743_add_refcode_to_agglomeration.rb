class AddRefcodeToAgglomeration < ActiveRecord::Migration[6.0]
  def change
    add_column :agglomerations, :ref_code, :string
  end
end
