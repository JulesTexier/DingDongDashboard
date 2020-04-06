class AddStatusFieldToLead < ActiveRecord::Migration[6.0]
  def change
    add_column :leads, :status, :string, default: 'tf_filled'
  end
end
