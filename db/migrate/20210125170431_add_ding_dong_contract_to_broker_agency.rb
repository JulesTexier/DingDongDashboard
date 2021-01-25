class AddDingDongContractToBrokerAgency < ActiveRecord::Migration[6.0]
  def change
    add_column :broker_agencies, :only_dd_users, :boolean, default: false
  end
end
