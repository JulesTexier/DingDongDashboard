class AddStatusFieldToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :status, :string, default: 'form_filled'
  end
end
