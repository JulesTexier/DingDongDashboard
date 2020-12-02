class AddCurrentLeadsPeriodToBrokerAgencyTable < ActiveRecord::Migration[6.0]
  def change
    add_column :broker_agencies, :current_period_provided_leads, :integer, default:0
  end
end
