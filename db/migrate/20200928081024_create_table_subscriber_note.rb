class CreateTableSubscriberNote < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriber_notes do |t|
      t.text :content
      t.references :subscriber, index:true, foreign_key: true
    end
  end
end
