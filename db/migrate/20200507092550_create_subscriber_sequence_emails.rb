class CreateSubscriberSequenceEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriber_sequence_emails do |t|
      t.references :sequence_email, null: false, foreign_key: true
      t.references :subscriber, null: false, foreign_key: true

      t.timestamps
    end
  end
end
