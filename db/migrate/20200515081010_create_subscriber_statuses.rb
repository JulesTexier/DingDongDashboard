class CreateSubscriberStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriber_statuses do |t|
      t.belongs_to :status
      t.belongs_to :subscriber
      t.timestamps
    end
  end
end
