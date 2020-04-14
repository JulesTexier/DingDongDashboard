class AddBrokerIdToLead < ActiveRecord::Migration[6.0]
  def change
    add_reference :leads, :broker, index: true
  end
end
