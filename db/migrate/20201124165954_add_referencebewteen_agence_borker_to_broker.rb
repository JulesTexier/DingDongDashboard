class AddReferencebewteenAgenceBorkerToBroker < ActiveRecord::Migration[6.0]
  def change
    add_reference :brokers, :broker_agency, index: true
  end
end
