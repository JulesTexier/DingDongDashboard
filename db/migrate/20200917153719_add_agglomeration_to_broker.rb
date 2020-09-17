class AddAgglomerationToBroker < ActiveRecord::Migration[6.0]
  def change
    add_reference :brokers, :agglomeration, index: true
  end
end
