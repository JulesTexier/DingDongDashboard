class AddStatusFieldToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :status, :string, default: 'form_filled'
    add_column :subscribers, :project_type, :string
    add_column :subscribers, :has_messenger, :boolean
    add_column :subscribers, :specific_criteria, :text
    add_column :subscribers, :additional_question, :text
  end
end
