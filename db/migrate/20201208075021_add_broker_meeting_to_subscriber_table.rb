class AddBrokerMeetingToSubscriberTable < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :broker_meeting, :datetime
  end
end
