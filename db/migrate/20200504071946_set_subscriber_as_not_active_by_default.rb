class SetSubscriberAsNotActiveByDefault < ActiveRecord::Migration[6.0]
  def change
    change_column :subscribers, :is_active, :boolean, default: false
  end
end
