class CreateBrokerAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :broker_agencies do |t|
      t.string :name
      t.integer :max_period_leads, default: 100
      t.integer :current_period_leads_left, default: 100
      t.integer :default_pricing_lead, default: 6
      t.belongs_to :agglomeration
      t.string :status, default: "test"
      t.timestamps
    end
  end
end
