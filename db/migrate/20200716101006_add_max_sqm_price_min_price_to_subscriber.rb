class AddMaxSqmPriceMinPriceToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :min_price, :integer, default: 0
    add_column :subscribers, :max_sqm_price, :integer
  end
end
