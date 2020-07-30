class RemoveColumnsFromSubscribers < ActiveRecord::Migration[6.0]
  def up
    remove_column :subscribers, :specific_criteria, :text
    remove_column :subscribers, :additional_question, :text
    remove_column :subscribers, :initial_areas, :string
    remove_column :subscribers, :stripe_session_id, :string
    remove_column :subscribers, :status, :string
  end

  def down
    add_column :subscribers, :specific_criteria, :text
    add_column :subscribers, :additional_question, :text
    add_column :subscribers, :initial_areas, :string
    add_column :subscribers, :stripe_session_id, :string
    add_column :subscribers, :status, :string
  end
end
