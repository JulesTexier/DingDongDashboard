class AddStripeCustomerIdToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :stripe_session_id, :string
    add_column :subscribers, :is_blocked, :boolean
  end
end
