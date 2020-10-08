class AddHotLeadFieldtoSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :hot_lead, :boolean, default: false
  end
end
